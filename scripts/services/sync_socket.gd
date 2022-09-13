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
var _sent = _SENT_TEMPLATE.duplicate(true)
var _received = _RECEIVED_TEMPLATE.duplicate(true)

func _reset() -> void:
	_client.disconnect_from_host()
	_peer_node_uuid = ""
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

func _send_bad_apple_message():
	_send_message({
	"session": "reimu-hakurei",
	"type": "bad-apple",
	"timestamp": Datetime.new().to_iso_timestamp()
})

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
		"sync-full-meta-query":
			_sync_full_meta_query_message_handler(message)
		"sync-full-entries-query":
			_sync_full_entries_query_message_handler(message)
		"goodbye":
			_goodbye_message_handler(message)
		_:
			Logcat.info("Unrecognized message received: (%s)" % message.type)
			Logcat.info(str(message))

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
				entries = Database.Entry.find_by_uuids(following_histories.map(func (item): return item["entryUuid"]))
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

func _sync_full_entries_query_message_handler(message):
	var uuids = message.payload.uuids
	var entries = []
	if len(uuids) > 0:
		entries = Database.Entry.find_by_uuids(uuids)
	_reply_message(
		message, {
			"type": "sync-full-entries-response",
			"payload": {
				"entries": entries
			}
		}
	)

func _goodbye_message_handler(_message):
	_received['goodbye'] = true
	Logcat.info("Received goodbye message from peer node.")
