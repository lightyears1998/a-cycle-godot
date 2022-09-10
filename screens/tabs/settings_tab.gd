extends VBoxContainer

const ServerManagementScreen = preload("res://screens/server_management_screen.tscn")
const ExportScreen = preload("res://screens/export_screen.tscn")
const LogcatScreen = preload("res://screens/logcat_screen.tscn")

func _on_manage_servers_button_pressed():
	Screens.go_to(ServerManagementScreen.instantiate())

func _on_export_button_pressed():
	Screens.go_to(ExportScreen.instantiate())

func _on_logcat_button_pressed():
	Screens.go_to(LogcatScreen.instantiate())
