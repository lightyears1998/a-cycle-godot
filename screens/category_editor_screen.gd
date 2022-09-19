extends VBoxContainer

@onready var category_name_edit = %CategoryNameEdit as LineEdit
@onready var category_tree_control = %CategoryTreeControl as Tree
@onready var category_tree_control_root = category_tree_control.create_item()

var _tree = Database.Category.get_tree()
var _selected_tree_item = null

func _ready():
	_setup_tree_control()

func _setup_tree_control():
	category_tree_control_root.set_text(0, "All Categories")
	for uid in _tree:
		var node = _tree[uid]
		if node["parent_uid"].is_empty():
			_create_tree_control_item(category_tree_control_root, node)

func _create_tree_control_item(parent_item, node: Dictionary):
	var item = category_tree_control.create_item(parent_item)
	item.set_text(0, node.name)
	item.set_metadata(0, node)
	for child_uid in node["children_uids"]:
		_create_tree_control_item(item, _tree[child_uid])

func _on_category_tree_control_item_selected():
	_selected_tree_item = category_tree_control.get_selected()

func _on_category_tree_control_nothing_selected():
	_selected_tree_item = null

func _on_create_button_pressed():
	var item = category_tree_control.create_item(_selected_tree_item)
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
		_selected_tree_item.free()
		_selected_tree_item = null
