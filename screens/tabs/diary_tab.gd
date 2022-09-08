extends VBoxContainer

const DiaryEditorScreen = preload("res://screens/diary_editor_screen.tscn")

var _datetime_dict = Time.get_datetime_dict_from_system()

@export var datetime_dict: Dictionary:
	get:
		return _datetime_dict
	set(value):
		_datetime_dict = value
		_update_ui()

@onready var date_label = %DateLabel as Label

func _get_date_string() -> String:
	return "%04d-%02d-%02d" % [datetime_dict["year"], datetime_dict["month"], datetime_dict['day']]

func _update_ui() -> void:
	date_label.text = _get_date_string()

func _ready() -> void:
	_update_ui()

func _on_previous_day_button_pressed() -> void:
	datetime_dict = Datetime.get_previous_day(datetime_dict)

func _on_next_day_button_pressed() -> void:
	datetime_dict = Datetime.get_next_day(datetime_dict)

func _on_add_diary_button_pressed() -> void:
	Screens.go_to(DiaryEditorScreen.instantiate())

func _on_remove_diary_button_pressed() -> void:
	pass
