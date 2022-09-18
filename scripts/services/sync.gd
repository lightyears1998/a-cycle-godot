extends Node
class_name SyncService

var _restful = load("res://scripts/services/sync_restful.gd").new()
var _socket = load("res://scripts/services/sync_socket.gd").new()

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

func sync_with_all_servers() -> void:
	for config in Settings.app_config.sync_servers:
		if not config.enabled:
			Logcat.info("Skipping disabled config %s." % config.get_identifier())
			continue

		Logcat.info("Syncing with %s." % config.get_identifier())
		await self.prepare_sync(config)
		for idx in range(3):
			Logcat.info("Performing sync #%d for %s." % [(idx + 1), config.get_identifier()])
			await Service.Sync.sync(config)
