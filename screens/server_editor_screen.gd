extends VBoxContainer

signal save_button_pressed(saved_config: SyncServerConfig)

var config = SyncServerConfig.new()

@onready var url_edit = %UrlEdit as LineEdit
@onready var username_edit = %UsernameEdit as LineEdit
@onready var password_edit = %PasswordEdit as LineEdit

@onready var test_result_label = %TestResultLabel as Label
@onready var http_request = %HttpRequest as HTTPRequest

func _ready():
	url_edit.text = config.url
	username_edit.text = config.username
	password_edit.text = config.password

func _on_test_button_pressed():
	test_result_label.text = "Testing..."
	var err = http_request.request(url_edit.text)
	if err != OK:
		test_result_label.text = "Error: " + str(err)
	# TODO

func _on_save_button_pressed():
	config.url = url_edit.text
	config.username = username_edit.text
	config.password = password_edit.text
	emit_signal("save_button_pressed", config)
