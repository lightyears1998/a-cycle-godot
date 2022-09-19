extends VBoxContainer

var FocusClock = preload("res://screens/focus_clock.tscn")

@onready var clocking_label = %ClockingLabel as Label
@onready var status_label = %StatusLabel as Label
@onready var title_edit = %TitleEdit as LineEdit
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
			clocking_label.text = Service.Focus.get_clock_text()
		FocusService.Status.PAUSED:
			status_label.text = "Paused."
			start_pause_button.text = "Continue"
			finish_button.disabled = true

func _ready():
	_update_ui()

func _physics_process(_delta):
	_update_ui()

func _on_start_pause_button_pressed():
	match Service.Focus.status:
		FocusService.Status.STOPPED:
			Service.Focus.set_status(FocusService.Status.FOCUSING)
		FocusService.Status.FOCUSING:
			Service.Focus.set_status(FocusService.Status.PAUSED)
		FocusService.Status.PAUSED:
			Service.Focus.set_status(FocusService.Status.FOCUSING)
	_update_ui()

func _on_finish_button_pressed():
	if Service.Focus.status == FocusService.Status.FOCUSING or Service.Focus.status == FocusService.Status.PAUSED:
		Service.Focus.set_status(FocusService.Status.STOPPED)
		_update_ui()

func _on_clock_mode_button_pressed():
	Screens.go_to(FocusClock.instantiate())
