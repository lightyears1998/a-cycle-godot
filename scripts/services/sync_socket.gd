extends Node

signal _sync_completed_or_errored

const _C2S_TEMPLATE = {
	"said_goodbye": false
}

const _S2C_TEMPLATE = {
	"said_goodbye": false
}

var _client = WebSocketClient.new()
var _c2s = _C2S_TEMPLATE.duplicate(true)
var _s2c = _S2C_TEMPLATE.duplicate(true)

func _reset():
	_client.disconnect_from_host()
	_c2s = _C2S_TEMPLATE.duplicate(true)
	_s2c = _S2C_TEMPLATE.duplicate(true)

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

func _send_message(message: Dictionary):
	if not "session" in message:
		message["session"] = Utils.uuidv4()
	if not "errors" in message:
		message["errors"] = []
	if not "payload" in message:
		message["payload"] = {}
	message["timestamp"] = Datetime.new().to_iso_timestamp()
	_client.get_peer(1).put_packet(JSON.stringify(message).to_utf8_buffer())

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
	Logcat.verbose("Data received.")
	var data = _client.get_peer(1).get_packet().get_string_from_utf8()
	var message = JSON.parse_string(data)
	Logcat.info(str(message))

	match message.type:
		"handshake":
			Logcat.info("Hankshake message received.")
		"sync-recent-request":
			_sync_recent_request_message_handler(message)
		"sync-full-meta-query":
			_sync_full_meta_query_message_handler(message)
		"sync-full-entries-query":
			_sync_full_entries_query_message_handler(message)

func _sync_recent_request_message_handler(message):
	var cursor = message.payload["historyCursor"]
	if cursor:
		pass
	else:
		Logcat.info("Cursor (%s) is not a valid cursor. Replying with HistoryCursorInvalidError." % var_to_str(cursor))
		_reply_message(message, {
			"type": "sync-recent-response",
			"errors": ["HistoryCursorInvalidError"]
		})

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
