extends Control

@onready var dialog = %PromisedConfirmationDialog as PromisedConfirmationDialog

func _ready() -> void:
	dialog.add_button("Custom One", true, "custom_action")

	print('First popup test:')
	var decision = await dialog.prompt_user_to_make_decision()
	print(decision)

	await get_tree().create_timer(0).timeout

	print('Second popup test:')
	decision = await dialog.prompt_user_to_make_decision()
	print(decision)
