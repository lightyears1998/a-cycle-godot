extends Node

func save(peer_node: Dictionary) -> bool:
	peer_node["updatedAt"] = Datetime.new().to_unix_time()

	var sql_insert = "insert into peer_node (uuid, historyCursor, updatedAt) values (?, ?, ?)"
	var sql_update = "update set historyCursor=?, updatedAt=?"
	var sql = "%s on conflict do %s" % [sql_insert, sql_update]

	var ok = Database.db.query_with_bindings(sql, [
		peer_node.uuid,
		JSON.stringify(peer_node["historyCursor"]),
		peer_node["updatedAt"],
		JSON.stringify(peer_node["historyCursor"]),
		peer_node["updatedAt"]
	])
	if not ok:
		Logcat.error(Database.db.error_message)
		return false
	return true

func find_by_uuid(uuid: String) -> Dictionary:
	Database.db.select_rows("peer_node", "uuid='%s'" % uuid, ["*"])
	var nodes = Database.db.query_result
	if len(nodes) == 0:
		return {}
	var node = nodes.front()
	node["historyCursor"] = JSON.parse_string(node["historyCursor"])
	return node
