extends VBoxContainer

# TOOD implement draggable window and enable borderless window

@onready var _previous_window_position = $/root.position
@onready var _previous_window_size = $/root.size
#@onready var _previous_window_borderless_flag = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)
@onready var _previous_window_always_on_top_flag = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP)

@onready var clocking_label = %ClockingLabel as Label

func _ready():
#	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	$/root.size = self.custom_minimum_size
	move_to_bottom_right_cornor()
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)

func move_to_bottom_right_cornor():
	var screen_size = DisplayServer.get_display_safe_area().size
	var margin = Vector2i(32, 32)
	var window_position = screen_size - margin - Vector2i($/root.size)
	$/root.position = window_position

func _on_screen_destroy():
#	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, _previous_window_borderless_flag)
	$/root.position = _previous_window_position
	$/root.size = _previous_window_size
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, _previous_window_always_on_top_flag)

func _process(_delta):
	clocking_label.text = Service.Focus.get_clock_text()

func _on_restore_button_pressed():
	Screens.go_back()
