extends VBoxContainer

var ServerManagementScreen = preload("res://screens/server_management_screen.tscn")
var ExportScreen = preload("res://screens/export_screen.tscn")
var LogcatScreen = preload("res://screens/logcat_screen.tscn")
var WindowSettingsScreen = preload("res://screens/window_settings_screen.tscn")
var CategoryEditorScreen = preload("res://screens/category_editor_screen.tscn")

@onready var sync_button = %SyncButton as Button

func _on_sync_button_pressed() -> void:
	var previous_button_text = sync_button.text
	sync_button.text = "Syncing..."
	await SyncService.sync_with_all_servers()
	sync_button.text = previous_button_text

func _on_manage_servers_button_pressed():
	Screens.go_to(ServerManagementScreen.instantiate())

func _on_export_button_pressed():
	Screens.go_to(ExportScreen.instantiate())

func _on_logcat_button_pressed():
	Screens.go_to(LogcatScreen.instantiate())

func _on_window_settings_button_pressed():
	Screens.go_to(WindowSettingsScreen.instantiate())

func _on_category_editor_button_pressed():
	Screens.go_to(CategoryEditorScreen.instantiate())
