extends Node
class_name SyncService

var _restful = preload("res://scripts/services/sync_restful.gd").new()
var _socket = preload("res://scripts/services/sync_socket.gd").new()

func _enter_tree() -> void:
	add_child(_restful)
	add_child(_socket)

func prepare_sync(config: SyncServerConfig) -> void:
	return await _restful.prepare_sync(config)

func get_user_id(config: SyncServerConfig) -> String:
	return await _restful.get_user_id(config)

func get_user_token(config: SyncServerConfig) -> String:
	return await _restful.get_user_token(config)

func sync(config: SyncServerConfig) -> void:
	return await _socket.sync(config)
