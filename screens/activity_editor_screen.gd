extends VBoxContainer

var ActivityRepo = Database.Activity
var CategoryRepo = Database.Category

var activity = ActivityRepo.create()

@onready var title_edit = %TitleEdit as LineEdit
@onready var description_edit = %DescriptionEdit as LineEdit
@onready var category_picker = %CategoryPicker as CategoryPicker
@onready var start_datetime_edit = %StartDatetimeEdit
@onready var end_datetime_edit = %EndDatetimeEdit

func _ready():
	_update_ui()

func _update_ui():
	var content = activity["content"]
	title_edit.text = content["title"]
	description_edit.text = content["description"]
	_update_category_picker_ui()
	start_datetime_edit.datetime_dict = Datetime.from_unix_time(content["startDate"]).to_local_datetime_dict()
	end_datetime_edit.datetime_dict = Datetime.from_unix_time(content["endDate"]).to_local_datetime_dict()

func _update_category_picker_ui():
	var categories = activity["content"]["categories"]
	if len(categories) == 0:
		category_picker.sele
	CategoryRepo.find_by_category_uid()
