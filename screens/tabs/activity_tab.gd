extends VBoxContainer

var ActivityEditorScreen = preload("res://screens/activity_editor_screen.tscn")

var _activities := []
var _selected_activity_idx := -1
var _datetime := Datetime.new()

@onready var datetime_bar = %DatetimeBar as DatetimeBar
@onready var activity_list = %ActivityList as ItemList

func _ready() -> void:
	_on_screen_resume()

func _on_screen_resume() -> void:
	datetime_bar.set_datetime(_datetime)
	_read_activities()
	_update_ui()

func _read_activities() -> void:
	_activities = ActivityRepository.find_by_start_date(_datetime)
	_activities.sort_custom(func (a, b): return a.content["startDate"] < b.content["startDate"])

func _update_ui() -> void:
	activity_list.clear()
	for activity in _activities:
		var content = activity["content"]
		activity_list.add_item(
			"%s @ %s to %s" % [
				content["title"],
				Datetime.new(content["startDate"]).format("HH:mm"),
				Datetime.new(content["endDate"]).format("HH:mm"),
			]
		)
		activity_list.set_item_metadata(activity_list.item_count - 1, activity)
	if _selected_activity_idx != -1:
		if _selected_activity_idx < activity_list.item_count:
			activity_list.select(_selected_activity_idx)
		else:
			_selected_activity_idx = -1

func _on_datetime_bar_datetime_changed(datetime):
	_datetime = datetime
	_read_activities()
	_update_ui()

func _invoke_editor(activity: Dictionary = {}) -> void:
	var editor = ActivityEditorScreen.instantiate()
	if activity:
		editor.activity = activity
	editor.activity_changed.connect(func (_activity): _read_activities(); _update_ui())
	Screens.go_to(editor)

func _on_add_activity_button_pressed() -> void:
	_invoke_editor()

func _on_edit_activity_button_pressed() -> void:
	if _selected_activity_idx != -1:
		var activity = activity_list.get_item_metadata(_selected_activity_idx)
		_invoke_editor(activity)

func _on_remove_activity_button_pressed() -> void:
	if _selected_activity_idx != -1:
		var activity = activity_list.get_item_metadata(_selected_activity_idx)
		ActivityRepository.soft_remove(activity)
		activity_list.remove_item(_selected_activity_idx)
		_selected_activity_idx = -1
	_read_activities()
	_update_ui()

func _on_activity_list_item_selected(index: int) -> void:
	_selected_activity_idx = index
	_update_ui()
