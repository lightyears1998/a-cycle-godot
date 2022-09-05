extends Node

var go_back_stack := []

func go_back() -> bool:
	if len(go_back_stack) > 0:
		var last_screen = go_back_stack.pop_back()
		get_tree().change_scene(last_screen)
		return true
	return false

func go_to(path: String):
	var tree = get_tree()
	print_tree()
	# TODO push current sceen to 
#	var last_child = tree.

func _notification(what):
	if OS.get_name() == "Android":
		if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
			if !go_back():
				get_tree().quit()
