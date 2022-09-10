extends VBoxContainer

@onready var sync = %SyncService as SyncService

var server_config: SyncServerConfig

func _ready() -> void:
	server_config = Settings.app_config.sync_servers.front()

func _on_get_user_id_button_pressed() -> void:
	sync.get_user_id(server_config)

func _on_get_user_token_button_pressed() -> void:
	sync.get_user_token(server_config)
