extends VBoxContainer

@onready var log_container = %LogContainer as VBoxContainer

func _ready() -> void:
	_get_logs_in_buffer()
	Logcat.log_logged.connect(_on_log_logged)

func _get_logs_in_buffer():
	var idx: int = (Logcat.log_buffer_idx - 1 + Logcat.BUFFER_SIZE) % Logcat.BUFFER_SIZE
	while idx != Logcat.log_buffer_idx:
		var log_item = Logcat.log_buffer[idx]
		if log_item != null:
			_show_log(log_item.time, log_item.statement, log_item.level)
		idx = (idx - 1 + Logcat.BUFFER_SIZE) % Logcat.BUFFER_SIZE

func _show_log(time: Datetime, statement: String, level: String, prepend := false):
	var label= Label.new()
	label.text = time.to_iso_timestamp() + " " + level + "\n" + statement
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_container.add_child(label)
	if prepend:
		log_container.move_child(label, 0)

func _on_log_logged(time: Datetime, statement: String, level: String):
	_show_log(time, statement, level)
