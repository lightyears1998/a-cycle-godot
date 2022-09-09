extends VBoxContainer

const DiaryEditorScreen = preload("res://screens/diary_editor_screen.tscn")

@export var datetime_dict: Dictionary:
	get:
		return _datetime.to_local_datetime_dict()
	set(value):
		_datetime = Datetime.from_local_datetime_dict(value)
		_update_ui()

var DiaryRepo = DiaryRepository.new()

var _selected_diary_idx := -1
var _datetime := Datetime.new()

@onready var date_label = %DateLabel as Label

func _get_date_string() -> String:
	return "%04d-%02d-%02d" % [datetime_dict["year"], datetime_dict["month"], datetime_dict['day']]

func _update_diaries() -> void:
	var diaries = DiaryRepo.find_by_date(_datetime)
	print(diaries)

func _update_ui() -> void:
	date_label.text = _get_date_string()
	_update_diaries()

func _ready() -> void:
	_update_ui()

func _on_previous_day_button_pressed() -> void:
	datetime_dict = _datetime.get_previous_day().to_local_datetime_dict()

func _on_next_day_button_pressed() -> void:
	datetime_dict = _datetime.get_next_day().to_local_datetime_dict()

func _on_add_diary_button_pressed() -> void:
	Screens.go_to(DiaryEditorScreen.instantiate())

func _on_remove_diary_button_pressed() -> void:
	pass

func _on_edit_diary_button_pressed() -> void:
	pass # Replace with function body.

func _on_diary_list_item_selected(index: int) -> void:
	pass # Replace with function body.
