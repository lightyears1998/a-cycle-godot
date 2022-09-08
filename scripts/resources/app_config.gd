extends Resource
class_name AppConfig

@export var sync_servers: Array[Resource] = [] # Array[SyncServerConfig]
@export var node_uuid: String = Utils.uuidv4()

func _normalize():
	if node_uuid == "":
		node_uuid = Utils.uuidv4()
