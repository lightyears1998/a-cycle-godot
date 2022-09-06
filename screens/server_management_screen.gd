extends VBoxContainer

@onready var editor = %ServerEditorPopup as Popup
@onready var server_list = %ServerList as ItemList
@onready var sync_servers = Settings.app_config.sync_servers

func _ready():
	for item in sync_servers:
		server_list.add_item(item.url)

func _exit_tree():
	print('exited.')

func _on_add_server_button_pressed():
	editor.popup_centered()

func _on_edit_server_button_pressed():
	pass

func _on_remove_server_button_pressed():
	pass # Replace with function body.

func _on_server_editor_popup_popup_hide():
	print('hided.')

func _on_test_button_pressed():
	print("TT!")

func _on_save_button_pressed():
	editor.hide()
