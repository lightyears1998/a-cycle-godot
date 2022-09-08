extends VBoxContainer

signal _user_maded_go_back_decision

@onready var top_bar = %TopBar
@onready var datetime_edit = %DatetimeEdit
@onready var title_edit = %TitleEdit as LineEdit
@onready var content_edit = %ContentEdit as TextEdit

var _diary_saved := false
var _go_back_decision := false

func _ready() -> void:
	top_bar.before_go_back_hook = _before_go_back_check

func prompt_on_go_back() -> bool:
	var dialog = ConfirmationDialog.new()
	dialog.get_cancel_button().pressed.connect(
		func(): _go_back_decision = false; _user_maded_go_back_decision.emit()
	)
	dialog.get_ok_button().pressed.connect(
		func(): _go_back_decision = true; _user_maded_go_back_decision.emit()
	)
	add_child(dialog)
	dialog.popup_centered()
	await _user_maded_go_back_decision
	dialog.queue_free()
	return _go_back_decision

func _before_go_back_check() -> bool:
	if _diary_saved:
		return true
	var should_go_back = await prompt_on_go_back()
	return should_go_back
