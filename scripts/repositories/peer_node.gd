extends RefCounted
class_name PeerNodeRepository

func save(peer_node: Dictionary) -> bool:
	var sql_insert = "insert into peer_node (uuid, historyCursor, updatedAt) values (?, ?, ?)"
	var sql_update = "update set historyCursor=?, updatedAt=?"
	var sql = "%s on conflict do %s" % [sql_insert, sql_update]

	var ok = Database.db.query_with_bindings(sql, [
		peer_node.uuid, JSON.stringify(peer_node["historyCursor"]), peer_node["updatedAt"],
		JSON.stringify(peer_node["historyCursor"]), peer_node["updatedAt"]
	])
	if not ok:
		Logcat.error(Database.db.error_message)
		return false
	return true

func find_by_uuid(uuid: String) -> Dictionary:
	Database.db.select_rows("peer_node", "uuid='%s'" % uuid, ["*"])
	var node = Database.db.query_result.front()
	if node == null:
		return {}
	node["historyCursor"] = JSON.parse_string(node["historyCursor"])
	return node
