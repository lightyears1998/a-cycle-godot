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
	if "content" in entry:
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
	var ok = Database.EntryHistory.write_history(entry)
	if ok:
		ok = Database.db.insert_row('entry', _to_plain_dict(entry))
		if !ok:
			Logcat.error(Database.db.error_message)

func update(entry: Dictionary, update_stamp := true):
	if update_stamp:
		entry["updatedAt"] = Datetime.new().to_iso_timestamp()
		entry["updatedBy"] = Settings.app_config.node_uuid
	var ok = Database.EntryHistory.write_history(entry)
	if ok:
		ok = Database.db.update_rows('entry', "uuid='%s'" % entry.uuid, _to_plain_dict(entry))
		if !ok:
			Logcat.error(Database.db.error_message)

func save(entry: Dictionary):
	if entry.uuid:
		update(entry)
	else:
		insert(entry)

func save_if_new_or_fresher(new_entry: Dictionary):
	Logcat.verbose("Checking entry [%s] (%s)." % [new_entry.uuid, new_entry["updatedAt"]])
	var old_entry = find_by_uuid(new_entry.uuid, false)
	if old_entry:
		var old_entry_updated_at = Datetime.from_iso_timestamp(old_entry["updatedAt"]).to_unix_time()
		var new_entry_updated_at = Datetime.from_iso_timestamp(new_entry["updatedAt"]).to_unix_time()
		if new_entry_updated_at > old_entry_updated_at:
			Logcat.verbose("Updating entry because it is fresher. (compared to %s.)" % old_entry["updatedAt"])
			update(new_entry, false)
		else:
			Logcat.verbose("Skipped update because entry is not fresher. (compared to %s)" % old_entry["updatedAt"])
	else:
		Logcat.verbose("Saving entry because it is new.")
		insert(new_entry)

func filter_new_or_fresher_metadata(metadata_array: Array) -> Array:
	var result = []
	for metadata in metadata_array:
		var entry = find_by_uuid(metadata["uuid"], false)
		if entry:
			var entry_updated_at = Datetime.from_iso_timestamp(entry["updatedAt"]).to_unix_time()
			var metadata_updated_at = Datetime.from_iso_timestamp(metadata["updatedAt"]).to_unix_time()
			if metadata_updated_at > entry_updated_at:
				result.append(metadata)
		else:
			result.append(metadata)
	return result

func select_rows(
	query_condition: String,
	discard_removed := true,
	selected_columns := "*",
	skip := 0,
	take := 0,
) -> Array[Dictionary]:
	if discard_removed:
		if query_condition.strip_edges() == "":
			query_condition = "removedAt is null"
		else:
			query_condition += " and removedAt is null"

	var sql = "select %s from entry" % selected_columns
	if query_condition: sql += " where %s" % query_condition
	if take: sql += " limit %d" % take
	if skip: sql += " offset %d" % skip

	var ok = Database.db.query(sql)
	if not ok:
		return []
	var result = Database.db.query_result.duplicate()
	result.map(func (item): _from_plain_dict(item))
	return result

func find_by_uuid(uuid: String, discard_removed := true):
	var entries = select_rows("uuid='%s'" % uuid, discard_removed)
	if len(entries) == 0:
		return {}
	return entries[0]

func find_by_uuids(uuids: Array, discard_removed := true):
	var uuids_string = ', '.join(PackedStringArray(uuids.map(func(uuid): return "'%s'" % uuid)))
	var query_conditon = 'uuid in (%s)' % uuids_string
	return self.select_rows(query_conditon, discard_removed)

func soft_remove(entry: Dictionary):
	entry["removedAt"] = Datetime.new().to_iso_timestamp()
	update(entry)
