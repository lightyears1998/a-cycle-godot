extends Node
class_name SyncService

@onready var http_requset := PromisedHTTPRequest.new()

func _ready() -> void:
	add_child(http_requset)

func _exit_tree() -> void:
	http_requset.queue_free()

func get_user_id(config: SyncServerConfig):
	var url = config.get_restful_url()
	var result = await http_requset.request_async(url)
	if not result.error:
		print(result.response.body)
