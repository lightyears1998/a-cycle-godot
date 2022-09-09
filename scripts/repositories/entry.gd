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
	var created_at = Datetime.new().to_iso_timestamp()
	entry.uuid = null
	entry["createdAt"] = created_at
	entry["updatedAt"] = created_at
	entry["updatedBy"] = Settings.app_config.node_uuid
	return entry

func insert(entry: Dictionary):
	entry.uuid = Utils.uuidv4()
	var ok = Database.db.insert_row('entry', _to_plain_dict(entry))
	if !ok:
		Logcat.log(Database.db.error_message)

func update(entry: Dictionary, update_timestamp := true):
	if update_timestamp:
		entry["updatedAt"] = Datetime.new().to_iso_timestamp()
		entry["updatedBy"] = Settings.app_config.node_uuid
	var ok = Database.db.update_rows('entry', "uuid='%s'" % entry.uuid, _to_plain_dict(entry))
	if !ok:
		Logcat.log(Database.db.error_message)

func save(entry: Dictionary):
	if entry.uuid:
		update(entry)
	else:
		insert(entry)

func select_rows(query_condition: String, discard_removed := true) -> Array[Dictionary]:
	if discard_removed:
		if query_condition.strip_edges() == "":
			query_condition = "removedAt is null"
		else:
			query_condition += " and removedAt is null"
	var result = Database.db.select_rows('entry', query_condition, ["*"])
	result.map(func (item): _from_plain_dict(item))
	return result

func find_by_uuid(uuid: String):
	var entries = select_rows("uuid='%s'" % uuid)
	if len(entries) == 0:
		return {}
	return entries[0]

func soft_remove(entry: Dictionary):
	entry["removedAt"] = Datetime.new().to_iso_timestamp()
	update(entry)
