extends Node
class_name DatabaseSingleton

const CURRENT_DATABASE_SCHEMA := 1

var db: SQLite = SQLite.new()

var Entry = EntryRepository.new()
var EntryHistory = EntryHistoryRepository.new()
var Diary = DiaryRepository.new()
var TodoItem = TodoItemRepository.new()

func _init() -> void:
	var ok := _open_db()
	if ok:
		_maintenance()
		_create_table()

func _open_db() -> bool:
	db.path = Settings.db_path
	db.verbosity_level = SQLite.NORMAL if not Settings.is_dev_env() else SQLite.VERY_VERBOSE
	return db.open_db()

func _maintenance():
	db.create_table("metadata", {
		"key": { "data_type": "text", "primary_key": true },
		"value": { "data_type": "text", "not_null": true },
	})
	var schema := _get_or_create_schema_version()
	Logcat.info("Database schema version: %d." % schema)
	if schema != CURRENT_DATABASE_SCHEMA:
		_convert_schema(schema)

func _get_or_create_schema_version() -> int:
	var ok := db.query("select key, value from metadata where key='schema'")
	if !ok:
		return 0

	var result = db.query_result.duplicate(true)
	if len(result) == 0:
		db.query("insert into metadata (key, value) values ('schema', %d)" % CURRENT_DATABASE_SCHEMA)
		return CURRENT_DATABASE_SCHEMA

	var schema = str(result[0]).to_int()
	return schema

func _convert_schema(_old_schema: int) -> void:
	pass # placeholder for future

func _create_table():
	db.create_table("entry", {
		"uuid": { "data_type": "text", "primary_key": true },
		"removedAt": { "data_type": "text", "not_null": false },
		"contentType": { "data_type": "text" },
		"content": { "data_type": "text" },
		"createdAt": { "data_type": "text" },
		"updatedAt": { "data_type": "text" },
		"updatedBy": { "data_type": "text" },
	})
	db.create_table("entry_history", {
		"id": { "data_type": "int", "primary_key": true, "auto_increment": true },
		"entryUuid": { "data_type": "text" },
		"entryUpdatedAt": { "data_type": "text" },
		"entryUpdatedBy": { "data_type": "text" },
		"createdAt": { "data_type": "int" }
	})
	db.create_table("peer_node", {
		"uuid": { "data_type": "text", "primary_key": true },
		"historyCursor": { "data_type": "text", "default": "'{}'" },
		"updatedAt": { "data_type": "int" },
	})
