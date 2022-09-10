extends VBoxContainer

@onready var sync = %SyncService as SyncService

var sync_server_config: SyncServerConfig

func _ready() -> void:
	sync_server_config = Settings.app_config.sync_servers.front()

func _on_get_user_id_button_pressed() -> void:
	sync.get_user_id(sync_server_config)
