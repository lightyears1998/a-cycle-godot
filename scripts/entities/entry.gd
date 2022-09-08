extends RefCounted
class_name EntryRepository

const ENTRY_TEMPLATE = {
	"uuid": "uuid",
	"removedAt": null,
	"contentType": "text",
	"content": {},
	"createdAt": "timestamp",
	"updatedAt": "timestamp",
	"updatedBy": "uuid",
}

func _to_plain_dict(entry: Dictionary) -> Dictionary:
	var plain_dict = entry.duplicate(true)
	plain_dict.content = JSON.stringify(plain_dict.content)
	return plain_dict

func _from_plain_dict(entry: Dictionary) -> Dictionary:
	entry.content = JSON.parse_string(entry.content)
	return entry

func create() -> Dictionary:
	var entry = ENTRY_TEMPLATE.duplicate(true)
	var created_at = Datetime.new().to_unix_time()
	entry.uuid = null
	entry.createdAt = created_at
	entry.updatedAt = created_at
	entry.updatedBy = Settings.app_config.node_uuid
	return entry

func insert(entry: Dictionary):
	entry.uuid = Utils.uuidv4()
	var ok = Database.db.insert_row('entry', _to_plain_dict(entry))
	if !ok:
		print(Database.db.error_message)

func update(entry: Dictionary):
	var ok = Database.db.update_rows('entry', "uuid='%s'" % entry.uuid, _to_plain_dict(entry))
	if !ok:
		print(Database.db.error_message)

func save(entry: Dictionary):
	if not entry.uuid:
		insert(entry)
	else:
		update(entry)

func findByUuid(uuid: String):
	var entries = Database.db.select_rows('entry', "uuid='%s'" % uuid, ENTRY_TEMPLATE.keys())
	if len(entries) == 0:
		return {}
	return _from_plain_dict(entries[0])
