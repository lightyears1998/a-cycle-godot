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
	match Service.Focus.status:
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
	clocking_label.text = Service.Focus.get_clock_text()

func _ready():
	Service.Focus.focusing_activity_changed.connect(_on_focusing_activity_changed)
	_update_ui()

func _physics_process(_delta):
	_update_clocking_label()

func _on_focusing_activity_changed():
	var activity = Service.Focus.focusing_activity
	title_edit.text = activity.content.title
	category_picker.select_by_category_uids(activity.content["categories"])
	description_edit.text = activity.content.description

func _on_start_pause_button_pressed():
	match Service.Focus.status:
		FocusService.Status.STOPPED:
			Service.Focus.start_focusing()
		FocusService.Status.FOCUSING:
			Service.Focus.pause_focusing()
		FocusService.Status.PAUSED:
			Service.Focus.continue_focusing()
	_update_ui()

func _on_finish_button_pressed():
	if Service.Focus.status == FocusService.Status.FOCUSING or Service.Focus.status == FocusService.Status.PAUSED:
		Service.Focus.complete_focusing()
		_update_ui()

func _on_clock_mode_button_pressed():
	Screens.go_to(FocusClock.instantiate())

func _on_title_edit_text_changed(new_text):
	Service.Focus.focusing_activity["content"]["title"] = new_text

func _on_description_edit_text_changed() -> void:
	Service.Focus.focusing_activity["content"]["description"] = description_edit.text

func _on_category_picker_category_changed(category) -> void:
	Service.Focus.focusing_activity["content"]["categories"].clear()
	if category:
		Service.Focus.focusing_activity["content"]["categories"].append(category.uid)
