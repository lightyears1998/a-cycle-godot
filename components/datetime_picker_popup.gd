@tool
extends Popup

@export var datetime_dict = Time.get_datetime_dict_from_system()

@onready var year_edit = %YearEdit as SpinBox
@onready var month_edit = %MonthEdit as SpinBox
@onready var day_edit = %DayEdit as SpinBox
@onready var hour_edit = %HourEdit as SpinBox
@onready var minute_edit = %HourEdit as SpinBox
@onready var second_edit = %SecondEdit as SpinBox

signal datetime_changed(datetime_dict)

func _update_ui():
	if datetime_dict:
		year_edit.value = datetime_dict["year"]
		month_edit.value = datetime_dict["month"]
		day_edit.value = datetime_dict["day"]
		hour_edit.value = datetime_dict["hour"]
		minute_edit.value = datetime_dict["minute"]
		second_edit.value = datetime_dict["second"]

func _ready():
	_update_ui()

func _on_datetime_picker_popup_about_to_popup():
	_update_ui()

func _update_datetime_dict():
	datetime_dict["year"] = year_edit.value
	datetime_dict["month"] = month_edit.value
	datetime_dict["day"] = day_edit.value
	datetime_dict["hour"] = hour_edit.value
	datetime_dict["minute"] = minute_edit.value
	datetime_dict["second"] = second_edit.value

func _on_confirm_button_pressed():
	_update_datetime_dict()
	emit_signal("datetime_changed", datetime_dict)
	hide()

func _on_now_button_pressed():
	datetime_dict = Time.get_datetime_dict_from_system()
	_update_ui()
