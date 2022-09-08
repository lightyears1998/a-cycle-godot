extends Node

var db : SQLite = null
const db_path := "user://database.sqlite3"
const db_verbosity_level := SQLite.VERBOSE

var Entry = EntryEntity.new()
var Activity = ActivityEntity.new()
var Diary = DiaryEntity.new()

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

func _exit_tree():
	_clean_up()

func _clean_up():
	if db:
		db.close_db()
