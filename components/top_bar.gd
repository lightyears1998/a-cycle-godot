extends HBoxContainer

func _on_go_back_button_pressed():
	Screens.go_back()

func _on_button_pressed():
	print($root)
	print($/root)
	print(get_viewport())
