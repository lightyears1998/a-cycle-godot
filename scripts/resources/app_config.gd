extends Resource
class_name AppConfig
 
@export var sync_servers: Array[Resource] = [] # Array[SyncServerConfig]
@export var nodeUuid: String = Utils.uuidv4()

func _normalize():
	if nodeUuid == "":
		nodeUuid = Utils.uuidv4()
