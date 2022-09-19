extends HBoxContainer
class_name DatetimeBar

signal datetime_changed(datetime: Datetime)

@onready var datetime_label = %DatetimeLabel as Label

var _datetime := Datetime.new()

func _ready():
	_update_ui()

func _update_ui():
	datetime_label.text = _datetime.format("YYYY-MM-DD")

func set_datetime(datetime: Datetime):
	_datetime = datetime

func _on_previous_day_button_pressed():
	_datetime = _datetime.get_previous_day()
	_update_ui()
	datetime_changed.emit(_datetime)

func _on_next_day_button_pressed():
	_datetime = _datetime.get_next_day()
	_update_ui()
	datetime_changed.emit(_datetime)
