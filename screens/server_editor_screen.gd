extends VBoxContainer

signal save_button_pressed(saved_config: SyncServerConfig)

var config = SyncServerConfig.new()
@onready var testing_config = config.duplicate() as SyncServerConfig

@onready var host_edit = %HostEdit as LineEdit
@onready var path_edit = %PathEdit as LineEdit
@onready var http_port_edit = %HttpPortEdit as LineEdit
@onready var ws_port_edit = %WsPortEdit as LineEdit
@onready var username_edit = %UsernameEdit as LineEdit
@onready var password_edit = %PasswordEdit as LineEdit
@onready var use_tls_check_box = %UseTlsCheckBox as CheckBox

@onready var test_result_label = %TestResultLabel as Label
@onready var http_request = %HttpRequest as HTTPRequest

func _ready():
	host_edit.text = config.host
	path_edit.text = config.path
	http_port_edit.text = str(config.http_port)
	ws_port_edit.text = str(config.ws_port)
	username_edit.text = config.username
	password_edit.text = config.password
	use_tls_check_box.button_pressed = config.use_tls

func _update_config_from_ui_input(config_to_update: SyncServerConfig):
	config_to_update.host = host_edit.text
	config_to_update.path = path_edit.text
	config_to_update.http_port = http_port_edit.text.to_int()
	config_to_update.ws_port = ws_port_edit.text.to_int()
	config_to_update.username = username_edit.text
	config_to_update.password = password_edit.text
	config_to_update.use_tls = use_tls_check_box.button_pressed

func _append_test_result(text: String):
	test_result_label.text += "\n"
	test_result_label.text += text

func _on_test_button_pressed():
	test_result_label.text = "Testing..."
	http_request.cancel_request()

	_update_config_from_ui_input(testing_config)
	_test_username()

func _on_save_button_pressed():
	_update_config_from_ui_input(config)
	emit_signal("save_button_pressed", config)

func _test_username():
	var request_url = testing_config.get_restful_url() + "/users?username=" + testing_config.username.uri_encode()
	http_request.request_completed.connect(_on_test_username_request_completed, CONNECT_ONESHOT)
	var err = http_request.request(request_url)
	if err != OK:
		_append_test_result("Error: " + error_string(err) + " " +str(err))
	_append_test_result("Requesting: " + request_url)

func _on_http_request_completed(result, response_code, _headers, body) -> Dictionary:
	if result != 0 or response_code != 200:
		_append_test_result("Error requesting username (result, response_code): (" + str(result) + " " + str(response_code) + ")")
		return {}

	var data = JSON.parse_string(body.get_string_from_utf8())
	_append_test_result(str(data))
	return data["payload"]

func _on_test_username_request_completed(result, response_code, _headers, body):
	var payload = _on_http_request_completed(result, response_code, _headers, body)

	if not payload.has("user") or not payload["user"].has("id"):
		_append_test_result("Error getting userId: User may not exist in this server.")
		return

	var user = payload["user"]
	_append_test_result("UserId: " + str(user["id"]))
	_test_password(user["id"])

func _test_password(user_id: String):
	var request_url = testing_config.get_restful_url() + "/users/" + str(user_id) + "/jwt-tokens"
	http_request.request_completed.connect(_on_test_password_request_completed, CONNECT_ONESHOT)
	var data = JSON.stringify({
		"passwordSha256": testing_config.password.sha256_text()
	})
	var err = http_request.request(request_url, [
		"Content-Type: application/json"
	], true, HTTPClient.METHOD_POST, data)
	if err != OK:
		_append_test_result("Error: " + error_string(err) + " " +str(err))
	_append_test_result("Requesting: " + request_url)

func _on_test_password_request_completed(result, response_code, _headers, body):
	var _payload = _on_http_request_completed(result, response_code, _headers, body)
	_append_test_result("Config OK.")
