extends Node
class_name DatabaseSingleton

var db: SQLite = SQLite.new()

func _init() -> void:
	_open_db()
	_create_table()

func _open_db():
	db.path = Settings.db_path
	db.verbosity_level = SQLite.NORMAL if not Settings.is_dev_env() else SQLite.VERY_VERBOSE
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
	db.create_table("peer_node", {
		"uuid": { "data_type": "text", "primary_key": true },
		"historyCursor": { "data_type": "text", "default": "'{}'" },
		"updatedAt": { "data_type": "int" },
	})
