extends VBoxContainer

const ServerManagementScreen = preload("res://screens/server_management_screen.tscn")

func _on_manage_server_button_pressed():
	Screens.go_to(ServerManagementScreen.instantiate())

func _on_backup_button_pressed():
	pass # Replace with function body.

func _on_view_log_button_pressed():
	pass # Replace with function body.
