extends VBoxContainer

@onready var category_name_edit = %CategoryNameEdit as LineEdit
@onready var category_tree = %CategoryTree as Tree
@onready var category_tree_root = category_tree.create_item()

var _selected_tree_item = null

func _ready():
	_create_tree()

func _create_tree():
	category_tree_root.set_text(0, "All Categories")

func _on_category_tree_item_selected():
	_selected_tree_item = category_tree.get_selected()

func _on_category_tree_nothing_selected():
	_selected_tree_item = null

func _on_create_button_pressed():
	var item = category_tree.create_item(_selected_tree_item)
	item.set_text(0, category_name_edit.text)

func _on_rename_button_pressed():
	pass # Replace with function body.

func _on_remove_button_pressed():
	var dialog = PromisedConfirmationDialog.new()
	dialog.dialog_text = "Are you sure to remove category?"
	add_child(dialog)
	var should_delete = await dialog.prompt_user_to_make_decision()
	dialog.queue_free()

	if should_delete and _selected_tree_item:
		category_tree_root.remove_child(_selected_tree_item)
		_selected_tree_item.free()
		_selected_tree_item = null
