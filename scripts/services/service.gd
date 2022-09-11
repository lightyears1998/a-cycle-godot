extends Node

var Sync := SyncService.new()
var Backup := BackupService.new()

func _init() -> void:
	Sync.name = "Sync"
	Backup.name = "Backup"

func _enter_tree() -> void:
	add_child(Sync)
	add_child(Backup)

func _exit_tree() -> void:
	Sync.queue_free()
	Backup.queue_free()
