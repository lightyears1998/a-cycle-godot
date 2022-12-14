extends HBoxContainer

@export var before_go_back_hook: Callable = func(): return true;

func _on_go_back_button_pressed() -> void:
	var should_go_back = true
	if not before_go_back_hook.is_null():
		# Linter reports a false positive `REDUNDANT_AWAIT` warning
		# We must `await` here because `before_go_back_hook` could be a "coroutine" callable
		@warning_ignore(redundant_await)
		should_go_back = await before_go_back_hook.call()
	if should_go_back:
		Screens.go_back_otherwise_quit()
