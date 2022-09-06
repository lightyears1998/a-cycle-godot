extends Node

var go_back_stack: Array[Node] = []

func _get_current_screen() -> Node:
	return $/root.get_children()[$/root.get_child_count() - 1]

func _replace_current_screen(new_screen: Node) -> void:
	var current_screen = _get_current_screen()
	$/root.remove_child(current_screen)
	$/root.add_child(new_screen)

func go_back() -> bool:
	if len(go_back_stack) > 0:
		var last_screen = go_back_stack.pop_back()
		_replace_current_screen(last_screen)
		last_screen.queue_free()
		return true
	return false

func go_back_otherwise_quit() -> void:
	var went_back = go_back()
	if not went_back:
		get_tree().quit()

func go_to(next_screen: Node) -> void:
	var current_screen = _get_current_screen()
	_replace_current_screen(next_screen)
	go_back_stack.push_back(current_screen)

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
