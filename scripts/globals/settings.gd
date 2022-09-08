extends Node

var app_config = AppConfig.new()
var save_path = "user://settings.tres"
var time_zone = Time.get_time_zone_from_system()

func _save():
	ResourceSaver.save(app_config, save_path)

func _load():
	var loaded_config = ResourceLoader.load(save_path, "AppConfig")
	if loaded_config:
		app_config = loaded_config
	app_config._normalize()

func _ready():
	_load()
	_print_settings()

func _exit_tree():
	_save()

func _print_settings():
	print("time_zone: ", time_zone)
