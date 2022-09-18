extends Node
class_name SettingsSingleton

var app_config = AppConfig.new()
var app_config_path = "user://app_config{suffix}.tres".format({"suffix": _get_file_suffix()})
var time_zone = Time.get_time_zone_from_system()
var db_path = "user://database{suffix}.sqlite3".format({"suffix": _get_file_suffix()})

func is_dev_env():
	return not OS.has_feature("standalone")

func _get_file_suffix() -> String:
	return "_dev" if is_dev_env() else ""

func _save_app_config():
	ResourceSaver.save(app_config, app_config_path)

func _is_app_config_exists():
	return File.new().file_exists(app_config_path)

func _load_app_config():
	if _is_app_config_exists():
		var loaded_config = ResourceLoader.load(app_config_path, "AppConfig")
		if loaded_config:
			app_config = loaded_config
		app_config._normalize()

func _ready():
	_load_app_config()
	_log_settings()

func _exit_tree():
	_save_app_config()

func _log_settings():
	Logcat.info("time_zone\t" + str(time_zone))
	Logcat.info('db_path  \t' + str(db_path))
	Logcat.info('node_uuid\t' + str(app_config.node_uuid))
