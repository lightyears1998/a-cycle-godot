extends Button

signal _user_confirmed;

var _should_crash := false

func _crash_the_application() -> void:
	OS.crash("User wants to crash the application.")

func _show_dialog() -> void:
	var dialog = ConfirmationDialog.new()
	dialog.dialog_text = "Do you want to crash the application?"
	
	dialog.get_ok_button().pressed.connect(
		func (): _should_crash = true; _user_confirmed.emit()
	)
	dialog.get_cancel_button().pressed.connect(func (): self._user_confirmed.emit())
	dialog.close_requested.connect(func (): self._user_confirmed.emit())
	dialog.go_back_requested.connect(func (): self._user_confirmed.emit())
	add_child(dialog)
	
	dialog.popup_centered()
	await _user_confirmed
	dialog.queue_free() 

func _on_crash_button_pressed() -> void:
	await _show_dialog()

	if _should_crash:
		_crash_the_application()
