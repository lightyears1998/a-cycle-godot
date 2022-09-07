extends VBoxContainer

@onready var export2clipboard_button = %ExportToClipboardButton

func _on_export_to_clipboard_button_pressed():
	DisplayServer.clipboard_set("Not implemented.")
	var button_text = export2clipboard_button.text
	export2clipboard_button.text = "Copied to clipboard!"
	await get_tree().create_timer(3).timeout
	export2clipboard_button.text = button_text
