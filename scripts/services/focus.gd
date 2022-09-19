extends Node
class_name FocusService

signal focusing_activity_changed

enum Status {
	STOPPED,
	FOCUSING,
	PAUSED,
}

var focusing_activity: Dictionary = Database.Activity.create()
var status: Status:
	get: return _status

var _status = Status.STOPPED

var start_unix_time = 0
var phase_start_unix_time = 0
var accumulated_unix_time = 0
var total_unix_time = 0

func reset():
	focusing_activity = Database.Activity.create()
	focusing_activity_changed.emit()
	_status = Status.STOPPED
	start_unix_time = 0
	phase_start_unix_time = 0
	accumulated_unix_time = 0
	total_unix_time = 0

func start_focusing():
	_set_status(Status.FOCUSING)

func pause_focusing():
	_set_status(Status.PAUSED)
	_save_activity_phase()

func continue_focusing():
	_set_status(Status.FOCUSING)

func complete_focusing():
	_set_status(Status.STOPPED)
	_save_activity_phase()
	reset()

func _save_activity_phase():
	focusing_activity.uuid = ""
	focusing_activity.content["startDate"] = int(phase_start_unix_time)
	focusing_activity.content["endDate"] = int(Time.get_unix_time_from_system())
	Database.Activity.save(focusing_activity)

func _set_status(next_status):
	var current_unix_time = Time.get_unix_time_from_system()
	match next_status:
		Status.STOPPED:
			accumulated_unix_time += current_unix_time - phase_start_unix_time
		Status.FOCUSING:
			if _status == Status.STOPPED:
				start_unix_time = current_unix_time
			phase_start_unix_time = current_unix_time
		Status.PAUSED:
			accumulated_unix_time += current_unix_time - phase_start_unix_time
	_status = next_status

func get_clock_text():
	var time_dict = Time.get_time_dict_from_unix_time(total_unix_time)
	return "%02d:%02d" % [
			time_dict["hour"] * 60 + time_dict["minute"],
			time_dict['second']
		]

func _physics_process(_delta):
	if _status == Status.FOCUSING:
		var current_unix_time = Time.get_unix_time_from_system()
		total_unix_time = accumulated_unix_time + current_unix_time - phase_start_unix_time
