extends Node

signal _sync_completed_or_errored

const _SENT_TEMPLATE = {
	"sync-full-meta-query-count": 0,
	"sync-full-entries-query-count": 0,
	"sync-recent-request-count": 0,
	"goodbye": false,
}

const _RECEIVED_TEMPLATE = {
	"sync-full-meta-response-count": 0,
	"sync-full-entries-response-count": 0,
	"sync-full-entries-response-first-cursor": null,
	"sync-recent-response-count": 0,
	"goodbye": false,
}

var _client = WebSocketClient.new()
var _peer_node_uuid: String = ""
var _has_sync_begun = false
var _sent = _SENT_TEMPLATE.duplicate(true)
var _received = _RECEIVED_TEMPLATE.duplicate(true)

func _reset() -> void:
	_client.disconnect_from_host()
	_peer_node_uuid = ""
	_has_sync_begun = false
	_sent = _SENT_TEMPLATE.duplicate(true)
	_received = _RECEIVED_TEMPLATE.duplicate(true)

func _ready() -> void:
	_client.connection_closed.connect(_on_connection_closed)
	_client.connection_error.connect(_on_connection_error)
	_client.connection_established.connect(_on_connection_established)
	_client.data_received.connect(_on_data_received)

func _process(_delta: float) -> void:
	_client.poll()

func sync(config: SyncServerConfig):
	_reset()

	var url = config.get_socket_url()
	Logcat.info("WebSocket is connecting: %s." % url)
	_client.connect_to_url(url, [], false, [
		"Authorization: Bearer %s" % config.token,
		"A-Cycle-Peer-Node-Uuid: %s" % Settings.app_config.node_uuid
	])

func _send_message(message: Dictionary) -> String:
	if not "session" in message:
		message["session"] = Utils.uuidv4()
	if not "errors" in message:
		message["errors"] = []
	if not "payload" in message:
		message["payload"] = {}
	message["timestamp"] = Datetime.new().to_iso_timestamp()
	var err = _client.get_peer(1).put_packet(JSON.stringify(message).to_utf8_buffer())
	if err != OK:
		Logcat.error("Error sending message: %s." % error_string(err))
	return message["session"]

func _reply_message(request: Dictionary, response: Dictionary):
	response["session"] = request["session"]
	_send_message(response)

func _is_sync_recent_ongoing() -> bool:
	return _sent['sync-recent-request-count'] > _received['sync-recent-response-count']

func _is_sync_full_excuted() -> bool:
	return _sent['sync-full-meta-query-count'] > 0

func _is_sync_full_ongoing() -> bool:
	return _sent['sync-full-meta-query-count'] > 0 && (
		_sent['sync-full-meta-query-count'] > _received['sync-full-meta-response-count'] ||
		_sent['sync-full-entries-query-count'] > _received['sync-full-entries-response-count']
	)

func _is_sync_full_succeed() -> bool:
	return _sent['sync-full-meta-query-count'] > 0 && (
		_sent['sync-full-meta-query-count'] <= _received['sync-full-meta-response-count']
	) && (
		_sent['sync-full-entries-query-count'] <= _received['sync-full-entries-response-count']
	)

func _send_bad_apple_message() -> void:
	var session_id =  _send_message({
		"session": "reimu-hakurei",
		"type": "bad-apple",
		"timestamp": Datetime.new().to_iso_timestamp()
	})
	Logcat.info("Sending BadAppleMessage, ooops... [%s]." % session_id)

func _on_connection_closed(was_clean_closed: bool):
	Logcat.info('WebSocket connection closed.')
	if not was_clean_closed:
		Logcat.verbose('WebSocket connection was not clean closed.')

func _on_connection_error():
	Logcat.info("WebSocket Connetion errored.")
	_sync_completed_or_errored.emit()

func _on_connection_established(protocol: String):
	Logcat.verbose("WebSocket connection established.")
	if protocol:
		Logcat.verbose("WebSocket connection is using protocol: %s")
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)

func _on_data_received():
	var data = _client.get_peer(1).get_packet().get_string_from_utf8()
	var message = JSON.parse_string(data)

	match message.type:
		"handshake":
			_handshake_message_handler(message)
		"sync-recent-request":
			_sync_recent_request_message_handler(message)
		"sync-recent-response":
			_sync_recent_response_message_handler(message)
		"sync-full-meta-query":
			_sync_full_meta_query_message_handler(message)
		"sync-full-meta-response":
			_sync_full_meta_response_message_handler(message)
		"sync-full-entries-query":
			_sync_full_entries_query_message_handler(message)
		"sync-full-entries-response":
			_sync_full_entries_response_message_handler(message)
		"goodbye":
			_goodbye_message_handler(message)
		_:
			Logcat.info("Unrecognized message received: (%s)" % message.type)
			Logcat.info(str(message))

	if _has_sync_begun and not _is_sync_recent_ongoing() and not _is_sync_full_ongoing() and not _sent['goodbye']:
		_send_message({
			"session": "goodbye",
			"type": "goodbye",
		})
		_sent['goodbye'] = true
		_clean_up_after_sync_full()
		Logcat.info("We are not syncing anything from peer, and it's time to say goodbye.")

	if _sent['goodbye'] and _received['goodbye']:
		_client.disconnect_from_host()
		Logcat.info("Two-way synchronziation finished.")

func _handshake_message_handler(message):
	Logcat.info("Handshake message received.")
	var payload = message.payload
	if payload:
		_peer_node_uuid = payload["serverUuid"]
		Logcat.info("Got server uuid %s from handshake message." % _peer_node_uuid)
	else:
		Logcat.error("Handshake message doesn't include server uuid.")
		_client.disconnect_from_host()
		_sync_completed_or_errored.emit()

	_init_sync_from_peer_node()

func _init_sync_from_peer_node():
	var node = Database.PeerNode.find_by_uuid(_peer_node_uuid)
	if node:
		Logcat.info("Node record found, performing recent-sync.")
		Logcat.info("Found cursor: %s" % str(node["historyCursor"]))
		_send_sync_recent_request_message(node["historyCursor"])
	else:
		Logcat.info("Node record not found, recording this node and peforming full-sync.")
		node = {
			"uuid": _peer_node_uuid,
			"historyCursor": {}
		}
		Database.PeerNode.save(node)
		_send_sync_full_meta_query_message(0)
	_has_sync_begun = true

func _send_sync_recent_request_message(history_cursor: Dictionary):
	var message_id = _send_message({
		"type": "sync-recent-request",
		"payload": {
			"historyCursor": history_cursor
		}
	})
	_sent["sync-recent-request-count"] += 1;
	Logcat.info("Sending sync recent request message #%s [%s]" % [_sent["sync-recent-request-count"], message_id])

func _send_sync_full_meta_query_message(skip: int):
	var message_id = _send_message({
		"type": "sync-full-meta-query",
		"payload": {
			"skip": skip,
		}
	})
	_sent["sync-full-meta-query-count"] += 1;
	Logcat.info("Sending sync full meta request message #%s [%s]" % [_sent["sync-full-meta-query-count"], message_id])

func _sync_recent_request_message_handler(message):
	Logcat.info("SyncRecentRequestMessage received.")

	var cursor = message.payload["historyCursor"]
	var reply_invalid_cursor_message = func ():
		Logcat.info("Cursor (%s) is not a valid cursor. Replying with HistoryCursorInvalidError." % var_to_str(cursor));
		_reply_message(message, {
			"type": "sync-recent-response",
			"errors": ["HistoryCursorInvalidError"],
		})

	if cursor:
		Logcat.info("Validating history cursor.")
		var ok = Database.EntryHistory.validate_history_cursor(cursor)
		if !ok:
			Logcat.info("History cursor invalid.")
			reply_invalid_cursor_message.call()
			return
		else:
			Logcat.info("History cursor valid.")
			var following_histories = Database.EntryHistory.get_following_histories(cursor)
			var next_cursor = cursor
			var entries = []
			if (len(following_histories) > 0):
				next_cursor = following_histories.back()
				entries = Database.Entry.find_by_uuids(following_histories.map(func (item): return item["entryUuid"]), false)
			else:
				Logcat.info("History cursor is the lastest cursor.")

			_send_message({
				"type": "sync-recent-response",
				"payload": {
					"historyCursor": next_cursor,
					"entries": entries
				}
			})
			Logcat.info("Replying SyncModeRecentResponseMessage.")
	else:
		reply_invalid_cursor_message.call()

func _sync_recent_response_message_handler(message):
	_received['sync-recent-response-count'] += 1
	Logcat.info("Receiving sync recent response message #%s [%s]." % [
		_received['sync-recent-response-count'], message.session
	])

	var errors = message.errors
	if len(errors) > 0:
		Logcat.info("Sync-recent failed due to errors: %s." % errors[0])
		Logcat.info("Fall back to sync-full.")

		var session = _send_message({
			"type": "sync-full-meta-query",
			"payload": {
				"skip": 0,
			}
		})
		_sent['sync-full-meta-query-count'] += 1
		Logcat.info("Sending sync full meta query message #%s [%s]." % [
			_sent['sync-full-meta-query-count'], session
		])
		return

	var history_cursor = message.payload["historyCursor"]
	var entries = message.payload['entries']

	if history_cursor:
		Database.PeerNode.save({
			"uuid": _peer_node_uuid,
			"historyCursor": history_cursor
		})

	for entry in entries:
		Database.Entry.save_if_new_or_fresher(entry)

	if len(entries) == 0:
		Logcat.info("Entries payload of received message is empty. Sync-full finishes.")
	else:
		var session = _send_message({
			"type": "sync-recent-request",
		})
		_sent['sync-recent-request-count'] += 1
		Logcat.info("Sending sync recent request #%s [%s]." % [_sent['sync-recent-request-count'], session])

func _sync_full_meta_query_message_handler(message):
	var skip = int(message.payload.skip)
	var current_cursor = Database.EntryHistory.get_last_history_cursor()
	var entry_metadata = Database.Entry.select_rows("", false, "uuid, createdAt, updatedAt, updatedBy", skip, 50)
	_reply_message(
		message, {
			"type": "sync-full-meta-response",
			"payload": {
				"skip": skip,
				"currentCursor": current_cursor,
				"entryMetadata": entry_metadata
			}
		}
	)

func _sync_full_meta_response_message_handler(message):
	var skip = message.payload["skip"]
	var current_cursor = message.payload["currentCursor"]
	var entry_metadata = message.payload["entryMetadata"]

	_received['sync-full-meta-response-count'] += 1
	Logcat.info("Receiving sync full meta response message #%s [%s]." % [
		_received['sync-full-meta-response-count'], message.session
	])

	if current_cursor:
		if _received['sync-full-entries-response-first-cursor'] == null:
			_received['sync-full-entries-response-first-cursor'] = current_cursor
			Logcat.info("Updating cursor from received sync full meta response message.")

	if len(entry_metadata) == 0:
		Logcat.info("No metadata received. Sync-full finished.")
		return

	var meta_query_message_sessoin =  _send_message({
		"type": "sync-full-meta-query",
		"payload": {
			"skip": skip + len(entry_metadata)
		},
	})
	_sent['sync-full-meta-query-count'] +=  1
	Logcat.info("Sending sync full meta query message #%s [%s]." % [
		_sent['sync-full-meta-query-count'], meta_query_message_sessoin
	])

	var fresher_metadata = Database.Entry.filter_new_or_fresher_metadata(entry_metadata)
	var entries_query_session =  _send_message({
		"type": "sync-full-entries-query",
		"payload": {
			"uuids": fresher_metadata.map(func (item): return item.uuid),
		},
	})
	_sent['sync-full-entries-query-count'] += 1
	Logcat.info("Sending sync full entries query #%s [%s]." % [
		_sent['sync-full-entries-query-count'], entries_query_session
	])

func _sync_full_entries_query_message_handler(message):
	var uuids = message.payload.uuids
	var entries = []
	if len(uuids) > 0:
		entries = Database.Entry.find_by_uuids(uuids, false)
	_reply_message(
		message, {
			"type": "sync-full-entries-response",
			"payload": {
				"entries": entries
			}
		}
	)

func _sync_full_entries_response_message_handler(message):
	var entries = message.payload.entries
	_received['sync-full-entries-response-count'] += 1
	Logcat.info("Receiving sync full entries response message #%s [%s]." % [
		_received['sync-full-entries-response-count'], message.session
	])

	for entry in entries:
		Database.Entry.save_if_new_or_fresher(entry)

func _goodbye_message_handler(_message):
	_received['goodbye'] = true
	Logcat.info("Received goodbye message from peer node.")

func _clean_up_after_sync_full():
	if _is_sync_full_excuted():
		if _is_sync_full_succeed() and _received['sync-full-entries-response-first-cursor']:
			Database.PeerNode.save({
				"uuid": _peer_node_uuid,
				"historyCursor": _received['sync-full-entries-response-first-cursor'],
			})
			Logcat.info("Sync full suceed and cursor is updated.")
		else:
			Logcat.info("Sync full has failed or no cursor was submitted by peer, and hence no cursor is updated.")
