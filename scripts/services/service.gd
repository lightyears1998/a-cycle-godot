extends Node

var Sync := SyncService.new()

func _init() -> void:
	Sync.name = "Sync"

func _enter_tree() -> void:
	add_child(Sync)

func _exit_tree() -> void:
	Sync.queue_free()
