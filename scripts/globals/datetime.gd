extends Node

## Get local datetime dict from system clock.
func get_datetime_dict() -> Dictionary:
	return Time.get_datetime_dict_from_system(false)

## Get ISO 8601 timestamp with timezone information.
## This timestamp is compatible with Node.js default Date converting from JSON.
func get_timestamp() -> String:
	return Time.get_datetime_string_from_system(true) + "Z"

## Get unix time in integer format.
func get_unix_time() -> int:
	return int(Time.get_unix_time_from_system())

func get_unix_time_from_timestamp(timestamp: String) -> int:
	timestamp = timestamp.trim_suffix("Z")
	var datetime_dict = Time.get_datetime_dict_from_datetime_string(timestamp, false)
	return Time.get_unix_time_from_datetime_dict(datetime_dict)

func _append_unix_time_offset_to_datetime_dict(datetime_dict: Dictionary, offset: int) -> Dictionary:
	var unix_time: int = Time.get_unix_time_from_datetime_dict(datetime_dict)
	unix_time += offset
	return Time.get_datetime_dict_from_unix_time(unix_time)

func get_next_day(datetime_dict: Dictionary) -> Dictionary:
	return _append_unix_time_offset_to_datetime_dict(datetime_dict, 60 * 60 * 24)

func get_previous_day(datetime_dict: Dictionary) -> Dictionary:
	return _append_unix_time_offset_to_datetime_dict(datetime_dict, -60 * 60 * 24)

func get_the_beginning_of_the_day(datetime_dict: Dictionary) -> Dictionary:
	var new_dict := datetime_dict.duplicate(true)
	new_dict["hour"] = 0
	new_dict["minute"] = 0
	new_dict["second"] = 0
	return new_dict

func get_the_end_of_the_day(datetime_dict: Dictionary) -> Dictionary:
	var new_dict := datetime_dict.duplicate(true)
	new_dict["hour"] = 23
	new_dict["minute"] = 59
	new_dict["second"] = 59
	return new_dict
