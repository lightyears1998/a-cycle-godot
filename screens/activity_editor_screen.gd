extends VBoxContainer

signal activity_changed(activity)

var activity = ActivityRepository.create()

@onready var title_edit = %TitleEdit as LineEdit
@onready var description_edit = %DescriptionEdit as TextEdit
@onready var category_picker = %CategoryPicker as CategoryPicker
@onready var start_datetime_edit = %StartDatetimeEdit
@onready var end_datetime_edit = %EndDatetimeEdit

func _ready():
	_update_ui()

func _update_ui():
	var content = activity["content"]
	title_edit.text = content["title"]
	description_edit.text = content["description"]
	category_picker.select_by_category_uids(content['categories'])
	start_datetime_edit.datetime_dict = Datetime.from_unix_time(content["startDate"]).to_local_datetime_dict()
	end_datetime_edit.datetime_dict = Datetime.from_unix_time(content["endDate"]).to_local_datetime_dict()

func _update_activity():
	var content = activity.content
	content["title"] = title_edit.text
	content["description"] = description_edit.text
	content["categories"].clear()
	if category_picker.selected_category != null:
		var category_uid = category_picker.selected_category.uid
		content["categories"].append(category_uid)
	content["startDate"] = Datetime.from_local_datetime_dict(start_datetime_edit.datetime_dict).to_unix_time()
	content["endDate"] = Datetime.from_local_datetime_dict(end_datetime_edit.datetime_dict).to_unix_time()

func _on_save_activity_button_pressed():
	_update_activity()
	ActivityRepository.save(activity)
	activity_changed.emit(activity)
