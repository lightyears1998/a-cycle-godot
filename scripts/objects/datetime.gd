extends RefCounted
class_name Datetime

var _local_unix_time := 0
var _local_unix_time_bias_from_utc := 0

func _init(unix_time: int = 0, unix_time_bias_from_utc := 0) -> void:
	if not unix_time:
		unix_time = int(Time.get_unix_time_from_system())
	_local_unix_time = unix_time
	_local_unix_time_bias_from_utc = unix_time_bias_from_utc
	_to_local()

static func now() -> Datetime:
	var unix_time = int(Time.get_unix_time_from_system())
	return Datetime.new(unix_time)

static func _get_time_zone_bias_seconds() -> int:
	return 60 * Settings.time_zone.bias

static func from_unix_time(unix_time: int) -> Datetime:
	return Datetime.new(unix_time)

## Convert an local datetime dict to Datetime object.
static func from_local_datetime_dict(local_datetime_dict) -> Datetime:
	var local_unix_time = Time.get_unix_time_from_datetime_dict(local_datetime_dict)
	var utc_unix_time = local_unix_time - _get_time_zone_bias_seconds()
	return Datetime.new(utc_unix_time)

static func from_iso_timestamp(iso_timestamp: String) -> Datetime:
	var datetime_string = iso_timestamp.trim_suffix("Z")
	var utc_unix_time = Time.get_unix_time_from_datetime_string(datetime_string)
	return Datetime.new(utc_unix_time)

## Get the local datetime dict representation of the Datetime object.
func to_local_datetime_dict() -> Dictionary:
	return Time.get_datetime_dict_from_unix_time(_local_unix_time)

## Get current "local" unix time.
func _to_local_unix_time() -> int:
	return _local_unix_time

## Get current unix time (UTC) in integer format.
func to_unix_time() -> int:
	return _local_unix_time - _local_unix_time_bias_from_utc

func _to_local() -> void:
	var bias_diff = _get_time_zone_bias_seconds() - _local_unix_time_bias_from_utc
	_local_unix_time += bias_diff
	_local_unix_time_bias_from_utc += bias_diff

func format(str: String) -> String:
	var datetime_dict = to_local_datetime_dict()
	str = str.replace("YYYY", str(datetime_dict['year']).lpad(4, '0'))
	str = str.replace("MM", str(datetime_dict['month']).lpad(2, '0'))
	str = str.replace("DD", str(datetime_dict['day']).lpad(2, '0'))
	str = str.replace('HH', str(datetime_dict['hour']).lpad(2, '0'))
	str = str.replace('mm', str(datetime_dict['minute']).lpad(2, '0'))
	str = str.replace('ss', str(datetime_dict['second']).lpad(2, '0'))
	return str

## Get current ISO 8601 timestamp with timezone information.
## This timestamp is compatible with Node.js default Date converting from JSON.
func to_iso_timestamp() -> String:
	return Time.get_datetime_string_from_unix_time(to_unix_time()) + "Z"

func get_next_day() -> Datetime:
	return Datetime.new(_local_unix_time + 60 * 60 * 24, _local_unix_time_bias_from_utc)

func get_previous_day() -> Datetime:
	return Datetime.new(_local_unix_time - 60 * 60 * 24, _local_unix_time_bias_from_utc)

func get_the_beginning_of_the_day() -> Datetime:
	var local_datetime_dict = to_local_datetime_dict()
	local_datetime_dict["hour"] = 0
	local_datetime_dict["minute"] = 0
	local_datetime_dict["second"] = 0
	return Datetime.new(
		Time.get_unix_time_from_datetime_dict(local_datetime_dict),
		_local_unix_time_bias_from_utc
	)

func get_the_end_of_the_day() -> Datetime:
	var local_datetime_dict = to_local_datetime_dict()
	local_datetime_dict["hour"] = 23
	local_datetime_dict["minute"] = 59
	local_datetime_dict["second"] = 59
	return Datetime.new(
		Time.get_unix_time_from_datetime_dict(local_datetime_dict),
		_local_unix_time_bias_from_utc
	)
