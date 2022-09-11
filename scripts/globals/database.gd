extends Node

var db: SQLite = null
var db_path: String = Settings.db_path
var db_verbosity_level := SQLite.NORMAL if not Settings.is_dev_env() else SQLite.VERY_VERBOSE

var Entry = EntryRepository.new()
var EntryHistory = EntryHistoryRepository.new()
var Activity = ActivityRepository.new()
var Diary = DiaryRepository.new()

var Entities = [
	Entry, Activity, Diary
]

func _ready():
	_open_db()
	_create_table()

func _open_db():
	db = SQLite.new()
	db.path = db_path
	db.verbosity_level = db_verbosity_level
	db.open_db()

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
	db.create_table("node", {
		"uuid": { "data_type": "text", "primary_key": true },
		"historyCursor": { "data_type": "text", "default": "null" },
		"updatedAt": { "data_type": "text" },
	})

func _exit_tree():
	_clean_up()

func _clean_up():
	if db:
		db.close_db()
