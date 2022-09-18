extends Node
class_name ServiceSingleton

var Sync = load("res://scripts/services/sync.gd").new()
var Backup = load("res://scripts/services/backup.gd").new()

func _init() -> void:
	Sync.name = "Sync"
	Backup.name = "Backup"

func _enter_tree() -> void:
	add_child(Sync)
	add_child(Backup)
