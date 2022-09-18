extends Node
class_name ScreensSingleton

var go_back_stack: Array[Node] = []

func _get_current_screen() -> Node:
	return $/root.get_children()[$/root.get_child_count() - 1]

func _change_screen_to(new_screen: Node) -> Node:
	var old_screen = _get_current_screen()
	$/root.remove_child(old_screen)
	$/root.add_child(new_screen)
	return old_screen

func go_back() -> bool:
	if len(go_back_stack) > 0:
		var previous_screen = go_back_stack.pop_back()
		var replaced_screen = _change_screen_to(previous_screen)
		replaced_screen.queue_free()
		if previous_screen.has_method("_on_screen_resume"):
			previous_screen._on_screen_resume()
		return true
	return false

func go_back_otherwise_quit() -> void:
	var went_back = go_back()
	if not went_back:
		get_tree().quit()

func go_to(next_screen: Node) -> void:
	var replaced_screen = _change_screen_to(next_screen)
	go_back_stack.push_back(replaced_screen)

func free_nodes_in_go_back_stack() -> void:
	while true:
		var node = go_back_stack.pop_back()
		if node:
			node.queue_free()
		else:
			break

func _exit_tree() -> void:
	free_nodes_in_go_back_stack()

func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			go_back_otherwise_quit()
		NOTIFICATION_WM_GO_BACK_REQUEST:
			go_back_otherwise_quit()
