extends Node

var go_back_stack: Array[Node] = []

func go_back() -> bool:
	if len(go_back_stack) > 0:
		var last_screen = go_back_stack.pop_back()
		get_tree().change_scene(last_screen)
		return true
	return false

func go_back_otherwise_quit() -> void:
	var went_back = go_back()
	if not went_back:
		get_tree().quit()

func go_to(path: String) -> void:
	var next_screen_packed = load(path) as PackedScene
	var next_screen = next_screen_packed.instantiate()
	var current_screen = $/root.get_children()[$/root.get_child_count() - 1]
	$/root.remove_child(current_screen)
	$/root.add_child(next_screen)

func clear_go_back_stack() -> void:
	while true:
		var node = go_back_stack.pop_back()
		if not node:
			break
		else:
			node.queue_free()

func _notification(what):
	if OS.get_name() == "Android":
		if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
			if !go_back():
				get_tree().quit()
