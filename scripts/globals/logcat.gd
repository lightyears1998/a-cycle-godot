extends Node

signal log_logged(timestamp: Datetime, statement: String, level: String)

const BUFFER_SIZE = 512

var log_buffer := Array()
var log_buffer_idx := 0

func _init() -> void:
	log_buffer.resize(BUFFER_SIZE)

func _write_to_stdout(time: Datetime, statement: String, level: String) -> void:
	printt("%s/%s" % [time.to_iso_timestamp(), level[0].to_upper()], statement)

func _write_to_log_buffer(time: Datetime, statement: String, level: String) -> void:
	log_buffer[log_buffer_idx] = {
		"time": time,
		"statement": statement,
		"level": level
	}
	log_buffer_idx = (log_buffer_idx + 1) % BUFFER_SIZE

func _log(statement: String, level: String) -> void:
	var time = Datetime.new()
	_write_to_stdout(time, statement, level)
	_write_to_log_buffer(time, statement, level)
	log_logged.emit(time, statement, level)

func verbose(statement: String) -> void:
	_log(statement, "verbose")

func debug(statement: String) -> void:
	_log(statement, "debug")

func info(statement: String) -> void:
	_log(statement, "info")

func warn(statement: String) -> void:
	_log(statement, "warn")

func error(statement: String) -> void:
	_log(statement, "error")

func panic(statement: String) -> void:
	_log(statement, "panic")
