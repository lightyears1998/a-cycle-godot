extends VBoxContainer

@onready var export_to_json_file_button = %ExportToJSONFileButton
@onready var export_to_json_file_button_file_dialog = %ExportToJSONFileButton/FileDialog as FileDialog

func _on_open_data_directory_button_pressed() -> void:
	var data_dir = ProjectSettings.globalize_path("user://")
	OS.shell_open("file://" + data_dir)

func _on_export_to_json_file_button_pressed():
	pass
