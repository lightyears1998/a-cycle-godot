extends MarginContainer

@onready var tab_container = %TabContainer
@onready var focus_tab = %FocusTab
@onready var activity_tab = %ActivityTab
@onready var todo_list_tab = %TodoListTab
@onready var ledger_tab = %LedgerTab
@onready var health_tab = %HealthTab
@onready var diary_tab = %DiaryTab
@onready var settings_tab = %SettingsTab

func _show_tab(tab: Node) -> void:
	for node in tab_container.get_children():
		node.visible = false
	tab.visible = true

func _ready() -> void:
	_show_tab(focus_tab)

func _on_focus_button_pressed() -> void:
	_show_tab(focus_tab)

func _on_activity_button_pressed() -> void:
	_show_tab(activity_tab)

func _on_todo_list_button_pressed() -> void:
	_show_tab(todo_list_tab)

func _on_ledger_button_pressed() -> void:
	_show_tab(ledger_tab)

func _on_health_button_pressed() -> void:
	_show_tab(health_tab)

func _on_diary_button_pressed() -> void:
	_show_tab(diary_tab)

func _on_settings_button_pressed() -> void:
	_show_tab(settings_tab)
