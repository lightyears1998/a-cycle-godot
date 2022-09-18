extends Node
class_name ServiceSingleton

var Sync = load("res://scripts/services/sync.gd").new() as SyncService
var Backup = load("res://scripts/services/backup.gd").new() as BackupService
var Focus = load("res://scripts/services/focus.gd").new() as FocusService

func _init() -> void:
	Sync.name = "SyncService"
	Backup.name = "BackupService"
	Focus.name = "FocusService"

func _enter_tree() -> void:
	add_child(Sync)
	add_child(Backup)
	add_child(Focus)
