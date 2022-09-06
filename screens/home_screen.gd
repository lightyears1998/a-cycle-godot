extends MarginContainer

const ServerManagementScreen = preload("res://screens/server_management_screen.tscn")

func _on_settings_button_pressed():
	Screens.go_to(ServerManagementScreen.instantiate())
