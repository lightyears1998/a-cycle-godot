extends Node

@onready var Sync = preload("res://scripts/services/sync.gd").new()
@onready var Backup = preload("res://scripts/services/backup.gd").new()

func _init() -> void:
	Sync.name = "Sync"
	Backup.name = "Backup"

func _enter_tree() -> void:
	add_child(Sync)
	add_child(Backup)
