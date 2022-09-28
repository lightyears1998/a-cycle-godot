extends VBoxContainer

var DiaryEditorScreen = preload("res://screens/diary_editor_screen.tscn")
var DiaryRepo = Database.Diary

var _diaries := []
var _selected_diary_idx := -1
var _datetime := Datetime.new()

@onready var datetime_bar = %DatetimeBar as DatetimeBar
@onready var diary_list = %DiaryList as ItemList
@onready var title_edit = %TitleEdit as LineEdit
@onready var content_edit = %ContentEdit as TextEdit

func _ready() -> void:
	_on_screen_resume()

func _on_screen_resume() -> void:
	datetime_bar.set_datetime(_datetime)
	_read_diaries()
	_update_ui()

func _read_diaries() -> void:
	_diaries = DiaryRepo.find_by_date(_datetime)
	_diaries.sort_custom(func (a, b): return a.content.date < b.content.date)

func _update_ui() -> void:
	diary_list.clear()
	for diary in _diaries:
		diary_list.add_item("%s @ %s" % [diary.content.title, Datetime.new(diary.content.date).format("HH:mm")])
		diary_list.set_item_metadata(diary_list.item_count - 1, diary)
	if _selected_diary_idx != -1:
		if _selected_diary_idx < diary_list.item_count:
			var diary = diary_list.get_item_metadata(_selected_diary_idx)
			title_edit.text = diary.content.title
			content_edit.text = diary.content.content
			diary_list.select(_selected_diary_idx)
		else:
			_selected_diary_idx = -1
	if _selected_diary_idx == -1:
		title_edit.text = ""
		content_edit.text = ""

func _on_datetime_bar_datetime_changed(datetime):
	_datetime = datetime
	_read_diaries()
	_update_ui()

func _invoke_editor(diary: Dictionary = {}) -> void:
	var editor = DiaryEditorScreen.instantiate()
	if diary:
		editor.diary = diary
	editor.diary_changed.connect(func (_diary): _read_diaries(); _update_ui())
	Screens.go_to(editor)

func _on_add_diary_button_pressed() -> void:
	_invoke_editor()

func _on_remove_diary_button_pressed() -> void:
	if _selected_diary_idx != -1:
		var diary = diary_list.get_item_metadata(_selected_diary_idx)
		var should_remove = await %RemoveDiaryConfirmationDialog.prompt_user_to_make_decision()
		if should_remove:
			DiaryRepo.soft_remove(diary)
			diary_list.remove_item(_selected_diary_idx)
			_selected_diary_idx = -1
	_update_ui()

func _on_edit_diary_button_pressed() -> void:
	if _selected_diary_idx != -1:
		var diary = diary_list.get_item_metadata(_selected_diary_idx)
		_invoke_editor(diary)

func _on_diary_list_item_selected(index: int) -> void:
	_selected_diary_idx = index
	_update_ui()
