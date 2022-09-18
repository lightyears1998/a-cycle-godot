extends Node
class_name FocusService

enum Status {
	STOPPED,
	FOCUSING,
	PAUSED,
}

var _status = Status.STOPPED
var status: Status:
	set(next_status): set_status(next_status)
	get: return _status

var start_unix_time = 0
var accumulated_unix_time = 0
var total_unix_time = 0

func set_status(next_status):
	match next_status:
		Status.STOPPED:
			accumulated_unix_time = 0
		Status.FOCUSING:
			start_unix_time = Time.get_unix_time_from_system()
		Status.PAUSED:
			var current_unix_time = Time.get_unix_time_from_system()
			accumulated_unix_time += current_unix_time - start_unix_time
	_status = next_status

func get_clock_text():
	var time_dict = Time.get_time_dict_from_unix_time(total_unix_time)
	return "%02d:%02d" % [
			time_dict["hour"] * 60 + time_dict["minute"],
			time_dict['second']
		]

func _process(_delta):
	if _status == Status.FOCUSING:
		var current_unix_time = Time.get_unix_time_from_system()
		total_unix_time = accumulated_unix_time + current_unix_time - start_unix_time
