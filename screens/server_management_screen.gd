extends VBoxContainer

const ServerEditorScreen = preload("res://screens/server_editor_screen.tscn")

@onready var server_list = %ServerList as ItemList

@onready var sync_servers = Settings.app_config.sync_servers as Array[Resource]

var editing_idx = -1

func _ready():
	for item in sync_servers:
		server_list.add_item(item.username + "@" + item.host)
		server_list.set_item_metadata(server_list.item_count - 1, item)

func _update_sync_server_configs():
	sync_servers.clear()
	for idx in range(server_list.item_count):
		var config = server_list.get_item_metadata(idx)
		sync_servers.push_back(config)

func _exit_tree():
	_update_sync_server_configs()

func _on_server_list_item_selected(index):
	editing_idx = index

func _on_add_server_button_pressed():
	editing_idx = -1
	var editor = ServerEditorScreen.instantiate()
	editor.config = SyncServerConfig.new()
	editor.save_button_pressed.connect(_on_editor_save_button_pressed)
	Screens.go_to(editor)

func _on_server_list_item_activated(_index):
	_on_edit_server_button_pressed()

func _on_edit_server_button_pressed():
	if editing_idx != -1:
		var config = server_list.get_item_metadata(editing_idx)
		var editor = ServerEditorScreen.instantiate()
		editor.config = config
		editor.save_button_pressed.connect(_on_editor_save_button_pressed)
		Screens.go_to(editor)

func _on_remove_server_button_pressed():
	if editing_idx != -1:
		var confirmation_dialog = ConfirmationDialog.new()
		confirmation_dialog.dialog_text = "Do you want to remove server?"
		add_child(confirmation_dialog)
		confirmation_dialog.get_ok_button().connect(
			"pressed", 
			func(): 
				server_list.remove_item(editing_idx);
				confirmation_dialog.queue_free();
				editing_idx = -1
		)
		confirmation_dialog.get_cancel_button().connect(
			"pressed", 
			func(): 
				confirmation_dialog.queue_free()
				editing_idx = -1
		)
		confirmation_dialog.popup_centered()

func _on_editor_save_button_pressed(config: SyncServerConfig):
	if editing_idx == -1:
		server_list.add_item(config.username + "@" + config.host)
		server_list.set_item_metadata(server_list.item_count - 1, config)
		editing_idx = server_list.item_count - 1
	else:
		server_list.set_item_text(editing_idx, config.host)
