extends Node

func get_timestamp() -> String:
	return Time.get_datetime_string_from_system(true) + "Z"

func get_unix_time() -> int:
	return int(Time.get_unix_time_from_system())

func get_unix_time_from_timestamp(timestamp: String) -> int:
	timestamp = timestamp.trim_suffix("Z")
	var datetime_dict = Time.get_datetime_dict_from_datetime_string(timestamp, false)
	return Time.get_unix_time_from_datetime_dict(datetime_dict)
