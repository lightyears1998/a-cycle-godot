extends VBoxContainer

@onready var sync = %SyncService as SyncService
@onready var logger = %Logger as CodeEdit

var server_config: SyncServerConfig

func _ready() -> void:
	server_config = Settings.app_config.sync_servers.front()
	Logcat.log_logged.connect(_on_log_logged)

func _on_log_logged(timestamp: Datetime, statement: String, level: String):
	logger.text += "%s %s\n%s\n" % [timestamp.to_iso_timestamp(), level, statement]

func _on_get_user_id_button_pressed() -> void:
	sync.get_user_id(server_config)

func _on_get_user_token_button_pressed() -> void:
	sync.get_user_token(server_config)
