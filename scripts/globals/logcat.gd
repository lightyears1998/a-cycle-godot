extends Node

signal log_logged(timestamp: Datetime, statement: String)

const BUFFER_SIZE = 512

var log_buffer := Array()
var log_buffer_idx := 0

func _init() -> void:
	log_buffer.resize(BUFFER_SIZE)

func _write_to_stdout(time: Datetime, statement: String) -> void:
	printt(time.to_iso_timestamp(), statement)

func _write_to_log_buffer(time: Datetime, statement: String) -> void:
	log_buffer[log_buffer_idx] = {
		"time": time,
		"statement": statement
	}
	log_buffer_idx = (log_buffer_idx + 1) % BUFFER_SIZE

func info(statement: String) -> void:
	var time = Datetime.new()
	_write_to_stdout(time, statement)
	_write_to_log_buffer(time, statement)
	log_logged.emit(time, statement)
