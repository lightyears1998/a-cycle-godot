@tool
extends HBoxContainer

@export var datetime_dict = {
	"year": 0,
	"month": 1,
	"day": 1,
	"hour": 0,
	"minute": 0,
	"second": 0
}

@onready var datetime_label = %DatetimeLabel as Label
@onready var pick_button = %PickButton as Button
@onready var clear_button = %ClearButton as Button
@onready var datetime_picker_popup = %DatetimePickerPopup as Popup

func _update_ui():
	if datetime_dict:
		datetime_label.text = Time.get_datetime_string_from_datetime_dict(datetime_dict, true)
	else:
		datetime_label.text = "No date"

func clear_datetime():
	datetime_dict = null

func _ready():
	_update_ui()

func _on_pick_button_pressed():
	datetime_picker_popup.datetime_dict = datetime_dict
	datetime_picker_popup.popup_centered()

func _on_clear_button_pressed():
	clear_datetime()
	_update_ui()

func _on_datetime_picker_popup_datetime_changed(new_datetime_dict):
	datetime_dict = new_datetime_dict
	_update_ui()
