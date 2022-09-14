extends VBoxContainer

var ServerManagementScreen = load("res://screens/server_management_screen.tscn")
var ExportScreen = load("res://screens/export_screen.tscn")
var LogcatScreen = load("res://screens/logcat_screen.tscn")

@onready var sync_button = %SyncButton as Button

func _on_sync_button_pressed() -> void:
	var previous_button_text = sync_button.text
	sync_button.text = "Syncing..."
	await Service.Sync.sync_with_all_servers()
	sync_button.text = previous_button_text

func _on_manage_servers_button_pressed():
	Screens.go_to(ServerManagementScreen.instantiate())

func _on_export_button_pressed():
	Screens.go_to(ExportScreen.instantiate())

func _on_logcat_button_pressed():
	Screens.go_to(LogcatScreen.instantiate())
