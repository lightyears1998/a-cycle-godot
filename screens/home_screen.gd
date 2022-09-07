extends MarginContainer

@onready var tab_container = %TabContainer
@onready var settings_tab = %SettingsTab

func _show_tab(tab: Node):
	for node in tab_container.get_children():
		node.visible = false
	tab.visible = true

func _on_settings_button_pressed():
	_show_tab(settings_tab)
