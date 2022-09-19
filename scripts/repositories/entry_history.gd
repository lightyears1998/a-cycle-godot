extends RefCounted
class_name EntryHistoryRepository

func write_history(entry: Dictionary) -> bool:
	var ok = Database.db.insert_row('entry_history', {
		"entryUuid": entry.uuid,
		"entryUpdatedAt": entry.updatedAt,
		"entryUpdatedBy": entry.updatedBy,
		"createdAt": Datetime.new().to_unix_time()
	})
	if !ok:
		Logcat.error(Database.db.error_message)
		return false
	return ok

func validate_history_cursor(history_cursor) -> bool:
	var result = Database.db.select_rows(
		'entry_history',
		"id=%s and entryUuid='%s' and entryUpdatedAt='%s' and entryUpdatedBy='%s'" % [
			history_cursor.id,
			history_cursor.entryUuid,
			history_cursor.entryUpdatedAt,
			history_cursor.entryUpdatedBy,
		],
		["*"])
	if result.front():
		return true
	return false

func get_following_histories(history_cursor: Dictionary) -> Array:
	var ok = Database.db.query_with_bindings(
		"select * from entry_history where id>? order by id asc limit 50", [
			history_cursor.id,
		])
	if not ok:
		return []
	return Database.db.query_result.duplicate()

func get_first_history_cursor() -> Dictionary:
	var ok = Database.db.query("select * from entry_history order by id asc limit 1")
	if not ok:
		return {}
	var cursor = Database.db.query_result.front()
	return cursor if cursor else {}

func get_last_history_cursor() -> Dictionary:
	var ok = Database.db.query("select * from entry_history order by id desc limit 1")
	if not ok:
		return {}
	if len(Database.db.query_result) == 0:
		return {}
	var cursor = Database.db.query_result.front()
	return cursor if cursor else {}
