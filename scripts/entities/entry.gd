extends RefCounted
class_name EntryEntity

const ENTRY_TEMPLATE = {
	"uuid": "uuid",
	"removedAt": null,
	"contentType": "text",
	"content": {},
	"createdAt": "timestamp",
	"updatedAt": "timestamp",
	"updatedBy": "uuid",
}

func create() -> Dictionary:
	var entry = ENTRY_TEMPLATE.duplicate(true)
	var created_at = Datetime.get_timestamp()
	entry.uuid = Utils.uuidv4()
	entry.createdAt = created_at
	entry.updatedAt = created_at
	entry.updatedBy = Settings.app_config.node_uuid
	return entry

func save():
	pass

func find():
	pass
