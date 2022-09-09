extends Node

var app_config := AppConfig.new()
var save_path := "user://settings{suffix}.tres".format({"suffix": _get_file_suffix()})
var time_zone := Time.get_time_zone_from_system()
var db_path := "user://database{suffix}.sqlite3".format({"suffix": _get_file_suffix()})

func is_dev_env():
	return not OS.has_feature("standalone")

func _get_file_suffix() -> String:
	return "_dev" if is_dev_env() else ""

func _save():
	ResourceSaver.save(app_config, save_path)

func _load():
	var loaded_config = ResourceLoader.load(save_path, "AppConfig")
	if loaded_config:
		app_config = loaded_config
	app_config._normalize()

func _ready():
	_load()
	_log_settings()

func _exit_tree():
	_save()

func _log_settings():
	Logcat.info("time_zone\t" + str(time_zone))
	Logcat.info('db_path  \t' + str(db_path))
	Logcat.info('node_uuid\t' + str(app_config.node_uuid))
