extends VBoxContainer

signal diary_changed(diary: Dictionary)
signal _user_made_go_back_decision

var DiaryRepo = load("res://scripts/repositories/diary.gd").new()

@export var diary: Dictionary = DiaryRepo.create()

@onready var top_bar = %TopBar
@onready var datetime_edit = %DatetimeEdit
@onready var title_edit = %TitleEdit as LineEdit
@onready var content_edit = %ContentEdit as TextEdit

var _diary_saved := true
var _go_back_decision := false

func _ready() -> void:
	top_bar.before_go_back_hook = _before_go_back_check
	datetime_edit.datetime_dict = Datetime.now().to_local_datetime_dict()
	title_edit.text = diary.content.title
	content_edit.text = diary.content.content

func prompt_on_go_back() -> bool:
	var dialog = ConfirmationDialog.new()
	dialog.dialog_text = "Do you want to discard the changes?"
	dialog.get_cancel_button().pressed.connect(
		func(): _go_back_decision = false; _user_made_go_back_decision.emit()
	)
	dialog.get_ok_button().pressed.connect(
		func(): _go_back_decision = true; _user_made_go_back_decision.emit()
	)
	add_child(dialog)
	dialog.popup_centered()
	await _user_made_go_back_decision
	dialog.queue_free()
	return _go_back_decision

func _before_go_back_check() -> bool:
	if _diary_saved:
		return true
	var should_go_back = await prompt_on_go_back()
	return should_go_back

func _on_diary_updated() -> void:
	_diary_saved = false

func _on_title_edit_text_changed(_next_text: String) -> void:
	_on_diary_updated()

func _on_content_edit_text_changed() -> void:
	_on_diary_updated()

func _on_save_diary_button_pressed() -> void:
	diary.content.date = datetime_edit.datetime.to_unix_time()
	diary.content.title = title_edit.text
	diary.content.content = content_edit.text
	DiaryRepo.save(diary)
	_diary_saved = true
	diary_changed.emit(diary)
