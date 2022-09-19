extends RefCounted
class_name EntryRepository

var EntryHistoryRepo = EntryHistoryRepository.new()

const ENTRY_CONTENT_TEMPLATE = {
	"uuid": "", # empty string or uuid
	"removedAt": null, # null or timestamp
	"contentType": "", # text
	"content": {},
	"createdAt": "", # timestamp
	"updatedAt": "", # timestamp
	"updatedBy": "", # updated uuid
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
	return _create()

func _create() -> Dictionary:
	var entry = ENTRY_CONTENT_TEMPLATE.duplicate(true)
	var created_at = Datetime.new().to_iso_timestamp()
	entry.uuid = ""
	entry["createdAt"] = created_at
	entry["updatedAt"] = created_at
	entry["updatedBy"] = Settings.app_config.node_uuid
	return entry

func fork(content_type: String, content: Dictionary) -> Dictionary:
	var entry = _create()
	entry["contentType"] = content_type
	entry["content"] = content
	return entry

func insert(entry: Dictionary) -> bool:
	if entry.uuid.is_empty():
		entry.uuid = Utils.uuidv4()
	var ok = EntryHistoryRepo.write_history(entry)
	if !ok:
		Logcat.error("Can't write entry history.")
		return false
	ok = Database.db.insert_row('entry', _to_plain_dict(entry))
	if !ok:
		Logcat.error(Database.db.error_message)
		return false
	return true

func update(entry: Dictionary, update_stamp := true) -> bool:
	if update_stamp:
		entry["updatedAt"] = Datetime.new().to_iso_timestamp()
		entry["updatedBy"] = Settings.app_config.node_uuid
	var ok = EntryHistoryRepo.write_history(entry)
	if !ok:
		Logcat.error("Error writing entry history.")
		return false
	ok = Database.db.update_rows('entry', "uuid='%s'" % entry.uuid, _to_plain_dict(entry))
	if !ok:
		Logcat.error(Database.db.error_message)
		return false
	return true

func save(entry: Dictionary) -> bool:
	if entry.uuid:
		return update(entry)
	else:
		return insert(entry)

func save_if_new_or_fresher(new_entry: Dictionary) -> bool:
	Logcat.verbose("Checking entry [%s] (%s)." % [new_entry.uuid, new_entry["updatedAt"]])
	var old_entry = find_by_uuid(new_entry.uuid, false)
	if old_entry:
		var old_entry_updated_at = Datetime.from_iso_timestamp(old_entry["updatedAt"]).to_unix_time()
		var new_entry_updated_at = Datetime.from_iso_timestamp(new_entry["updatedAt"]).to_unix_time()
		if new_entry_updated_at > old_entry_updated_at:
			Logcat.verbose("Updating entry because it is fresher. (compared to %s.)" % old_entry["updatedAt"])
			return update(new_entry, false)
		else:
			Logcat.verbose("Skipped update because entry is not fresher. (compared to %s)" % old_entry["updatedAt"])
			return false
	else:
		Logcat.verbose("Saving entry because it is new.")
		return insert(new_entry)

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

func soft_remove(entry: Dictionary) -> bool:
	entry["removedAt"] = Datetime.new().to_iso_timestamp()
	return update(entry)
