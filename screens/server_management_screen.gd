extends VBoxContainer

@onready var editor = %ServerEditorPopup as Popup
@onready var server_list = %ServerList as ItemList
@onready var url_edit = %UrlEdit as LineEdit
@onready var username_edit = %UsernameEdit as LineEdit
@onready var password_edit = %PasswordEdit as LineEdit
@onready var test_result_label = %TestResultLabel as Label
@onready var http_request = %HttpRequest as HTTPRequest

@onready var sync_servers = Settings.app_config.sync_servers as Array[Resource]

var editing_idx = -1

func _ready():
	for item in sync_servers:
		server_list.add_item(item.url)
		server_list.set_item_metadata(server_list.item_count - 1, item)

func _exit_tree():
	sync_servers.clear()
	for idx in range(server_list.item_count):
		var config = server_list.get_item_metadata(idx)
		sync_servers.push_back(config)

func _on_server_list_item_selected(index):
	editing_idx = index

func _on_add_server_button_pressed():
	editing_idx = -1
	url_edit.text = ""
	username_edit.text = ""
	password_edit.text = ""
	editor.popup_centered()

func _on_server_list_item_activated(_index):
	_on_edit_server_button_pressed()

func _on_edit_server_button_pressed():
	if editing_idx != -1:
		var config = server_list.get_item_metadata(editing_idx)
		url_edit.text = config.url
		username_edit.text = config.username
		password_edit.text = config.password
		editor.popup_centered()

func _on_remove_server_button_pressed():
	if editing_idx != -1:
		var confirmation_dialog = ConfirmationDialog.new()
		confirmation_dialog.dialog_text = "Do you want to remove server?"
		add_child(confirmation_dialog)
		confirmation_dialog.get_ok_button().connect(
			"pressed", 
			func(): server_list.remove_item(editing_idx); confirmation_dialog.queue_free()
		)
		confirmation_dialog.get_cancel_button().connect(
			"pressed", 
			func(): confirmation_dialog.queue_free()
		)
		confirmation_dialog.popup_centered()

func _on_test_button_pressed():
	test_result_label.text = "Testing..."

func _on_save_button_pressed():
	var config
	if editing_idx == -1:
		config = SyncServerConfig.new()
	else: 
		config = server_list.get_item_metadata(editing_idx)
	config.url = url_edit.text
	config.username = username_edit.text
	config.password = password_edit.text
	
	if editing_idx == -1:
		server_list.add_item(config.url)
		server_list.set_item_metadata(server_list.item_count - 1, config)
	editor.hide()
