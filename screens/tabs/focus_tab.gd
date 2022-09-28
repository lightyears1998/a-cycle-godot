extends VBoxContainer

var FocusClock = preload("res://screens/focus_clock.tscn")

@onready var clocking_label = %ClockingLabel as Label
@onready var status_label = %StatusLabel as Label
@onready var title_edit = %TitleEdit as LineEdit
@onready var category_picker = %CategoryPicker as CategoryPicker
@onready var description_edit = %DescriptionEdit as TextEdit
@onready var start_pause_button = %StartPauseButton as Button
@onready var finish_button = %FinishButton as Button

func _update_ui():
	match FocusService.status:
		FocusService.Status.STOPPED:
			status_label.text = "Waiting to start."
			start_pause_button.text = "Start"
			finish_button.disabled = true
		FocusService.Status.FOCUSING:
			status_label.text = "Focusing..."
			start_pause_button.text = "Pause"
			finish_button.disabled = false
		FocusService.Status.PAUSED:
			status_label.text = "Paused."
			start_pause_button.text = "Continue"
			finish_button.disabled = true

func _update_clocking_label():
	clocking_label.text = FocusService.get_clock_text()

func _ready():
	FocusService.focusing_activity_changed.connect(_on_focusing_activity_changed)
	_update_ui()

func _physics_process(_delta):
	_update_clocking_label()

func _on_focusing_activity_changed():
	var activity = FocusService.focusing_activity
	title_edit.text = activity.content.title
	category_picker.select_by_category_uids(activity.content["categories"])
	description_edit.text = activity.content.description

func _on_start_pause_button_pressed():
	match FocusService.status:
		FocusService.Status.STOPPED:
			FocusService.start_focusing()
		FocusService.Status.FOCUSING:
			FocusService.pause_focusing()
		FocusService.Status.PAUSED:
			FocusService.continue_focusing()
	_update_ui()

func _on_finish_button_pressed():
	if FocusService.status == FocusService.Status.FOCUSING or FocusService.status == FocusService.Status.PAUSED:
		FocusService.complete_focusing()
		_update_ui()

func _on_clock_mode_button_pressed():
	Screens.go_to(FocusClock.instantiate())

func _on_title_edit_text_changed(new_text):
	FocusService.focusing_activity["content"]["title"] = new_text

func _on_description_edit_text_changed() -> void:
	FocusService.focusing_activity["content"]["description"] = description_edit.text

func _on_category_picker_category_changed(category) -> void:
	FocusService.focusing_activity["content"]["categories"].clear()
	if category:
		FocusService.focusing_activity["content"]["categories"].append(category.uid)
