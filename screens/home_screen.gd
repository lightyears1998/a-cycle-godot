extends MarginContainer

@onready var tab_container = %TabContainer
@onready var focus_tab = %FocusTab
@onready var diary_tab = %DiaryTab
@onready var settings_tab = %SettingsTab

@onready var last_tab = focus_tab

func _show_tab(tab: Node) -> void:
	for node in tab_container.get_children():
		node.visible = false
	tab.visible = true

func _ready() -> void:
	_show_tab(last_tab)

func _on_focus_button_pressed() -> void:
	_show_tab(focus_tab)

func _on_diary_button_pressed() -> void:
	_show_tab(diary_tab)

func _on_settings_button_pressed() -> void:
	_show_tab(settings_tab)
