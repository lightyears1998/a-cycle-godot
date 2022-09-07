extends VBoxContainer

enum Status {
	STOPPED,
	FOCUSING,
	PAUSED,
}

var start_unix_time = 0
var accumulated_unix_time = 0
var status = Status.STOPPED

@onready var clocking_label = %ClockingLabel as Label
@onready var status_label = %StatusLabel as Label
@onready var title_edit = %TitleEdit as LineEdit
@onready var description_edit = %DescriptionEdit as TextEdit
@onready var start_pause_button = %StartPauseButton as Button
@onready var finish_button = %FinishButton as Button

func _update_state():
	match status:
		Status.STOPPED:
			accumulated_unix_time = 0
		Status.FOCUSING:
			start_unix_time = Time.get_unix_time_from_system()
		Status.PAUSED:
			var current_unix_time = Time.get_unix_time_from_system()
			accumulated_unix_time += current_unix_time - start_unix_time
	_update_ui()

func _update_ui():
	match status:
		Status.STOPPED:
			status_label.text = "Waiting to start."
			start_pause_button.text = "Start"
			finish_button.disabled = true
		Status.FOCUSING:
			status_label.text = "Focusing..."
			start_pause_button.text = "Pause"
			finish_button.disabled = false
		Status.PAUSED:
			status_label.text = "Paused."
			start_pause_button.text = "Continue"
			finish_button.disabled = true

func _ready():
	_update_state()

func _process_clock_update():
	if status == Status.FOCUSING:
		var current_unix_time = Time.get_unix_time_from_system()
		var total_unix_time = accumulated_unix_time + current_unix_time - start_unix_time
		var time_dict = Time.get_time_dict_from_unix_time(total_unix_time)
		clocking_label.text = "%02d:%02d" % [
			time_dict["hour"] * 60 + time_dict["minute"],
			time_dict['second']
		]

func _process(_delta):
	_process_clock_update()

func _on_start_pause_button_pressed():
	match status:
		Status.STOPPED:
			status = Status.FOCUSING
		Status.FOCUSING:
			status = Status.PAUSED
		Status.PAUSED:
			status = Status.FOCUSING
	_update_state()

func _on_finish_button_pressed():
	if status == Status.FOCUSING or status == Status.PAUSED:
		status = Status.STOPPED
		_update_state()
