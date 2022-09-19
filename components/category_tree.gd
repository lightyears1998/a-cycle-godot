# TODO
# 1. when remove a node, move its children to its parent.
# 2. Enable or disable editing on builtin categories.

extends VBoxContainer

signal category_selected(category_node: Dictionary)

@export var editable: bool:
	get: return _editable
	set(value):
		_editable = value
		if toolbar and toolbar.is_inside_tree():
			_update_toolbar_ui()

const CATEGORY_TREE_NODE_TEMPLATE := {
	"uid": "", # qualified name for kernel category or uuid for custom ones
	"parent_uid": "", # empty string or uid of parent category
	"children_uids": [], # Array of children uid
	"is_kernel": false,
	"name": "", # text
	"description": "", # text
	"entry": null, # Associated database entry, `null` for kernel categories
}

@onready var toolbar = %Toolbar
@onready var tree = %Tree as Tree
@onready var tree_root = tree.create_item()
@onready var name_edit = %NameEdit as LineEdit

var _editable = false
var _selected_tree_item = null
var _selected_node:
	get:
		if _selected_tree_item == null:
			return {}
		var node = _selected_tree_item.get_metadata(0)
		if node == null:
			return {}
		return node
var _map: Dictionary = {}

func _get_user_defined_category_map() -> Dictionary:
	var user_defined_entries = Database.Category.list()
	var user_defined_map = {}
	for entry in user_defined_entries:
		var node = {}
		var content = entry.content
		node["uid"] = content["uid"]
		node["parent_uid"] = content["parentUid"]
		node["children_uids"] = []
		node["is_kernel"] = false
		node["name"] = content["name"]
		node["description"] = content["description"]
		node["entry"] = entry
		user_defined_map[content["uid"]] = node
	for entry in user_defined_entries:
		var node = user_defined_map[entry.content["uid"]]
		if not node['parent_uid'].is_empty() and node['parent_uid'] in user_defined_map:
			user_defined_map[node['parent_uid']]["children_uids"].append(node.uid)
	return user_defined_map

func _build_builtin_category_tree_item(uid: String, parent_uid: String, node_name: String) -> Dictionary:
	var node = CATEGORY_TREE_NODE_TEMPLATE.duplicate(true)
	node["uid"] = uid
	node["parent_uid"] = parent_uid
	node["is_kernel"] = true
	node["name"] = node_name
	return node

func _get_builtin_categories_tree() -> Dictionary:
	var builtin_nodes = [
		_build_builtin_category_tree_item("kernel", "", "Kernel"),
		_build_builtin_category_tree_item("kernel/dining", "kernel", "Dining"),
		_build_builtin_category_tree_item("kernel/sleeping", "kernel", "Sleeping"),
		_build_builtin_category_tree_item("kernel/sports", "kernel", "Sports"),
		_build_builtin_category_tree_item("kernel/grooming", "kernel", "Grooming"),
		_build_builtin_category_tree_item("kernel/sumarizing", "kernel", "Sumarizing"),
	]
	var builtin_tree = {}
	for node in builtin_nodes:
		builtin_tree[node.uid] = node
		if not node["parent_uid"].is_empty():
			builtin_tree[node["parent_uid"]].children_uids.append(node.uid)
	return builtin_tree

func _update_node_entry(node):
	var content = node["entry"].content
	content["uid"] = node["uid"]
	content["parentUid"] = node["parent_uid"]
	content["name"] = node["name"]
	content["description"] = node["description"]

func _init():
	_build_map()

func _build_map():
	var builtin_map = _get_builtin_categories_tree()
	var user_defined_category_map = _get_user_defined_category_map()
	_map.merge(builtin_map)
	_map.merge(user_defined_category_map)

func _update_tree_ui():
	tree_root.set_text(0, "All Categories")
	for uid in _map:
		var node = _map[uid]
		if node["parent_uid"].is_empty():
			_attach_node_to_tree(tree_root, node)

func _attach_node_to_tree(parent_tree_item, node: Dictionary):
	var item = tree.create_item(parent_tree_item)
	item.set_text(0, node.name)
	item.set_metadata(0, node)
	for child_uid in node["children_uids"]:
		_attach_node_to_tree(item, _map[child_uid])

func _update_ui():
	_update_toolbar_ui()
	_update_tree_ui()

func _update_toolbar_ui():
	toolbar.visible = _editable

func _ready():
	_build_map()
	_update_ui()

func _on_tree_item_selected():
	_selected_tree_item = tree.get_selected()

func _on_tree_nothing_selected():
	_selected_tree_item = null

func _create_node(parent_uid: String, category_name: String) -> Dictionary:
	var node = CATEGORY_TREE_NODE_TEMPLATE.duplicate(true)
	node["uid"] = Utils.uuidv4()
	node["parent_uid"] = parent_uid
	node["name"] = category_name
	node["entry"] = Database.Category.create()
	return node

func _save_node(node: Dictionary) -> bool:
	if node.entry:
		_update_node_entry(node)
		return Database.Category.save(node.entry)
	return false

func _remove_node(node: Dictionary) -> bool:
	if node.entry:
		return Database.Category.soft_remove(node.entry)
	return false

func _on_create_button_pressed():
	var category_name = name_edit.text.strip_edges()
	if category_name.is_empty():
		return

	var selected_node = _selected_node
	var parent_uid = selected_node["uid"] if _selected_node else ""
	var neo_node = _create_node(parent_uid, category_name)
	if not _save_node(neo_node):
		Logcat.error("Error saving category. %s" % var_to_str(neo_node))
		return
	var neo_item = tree.create_item(_selected_tree_item)
	neo_item.set_text(0, name_edit.text)
	neo_item.set_metadata(0, neo_node)

func _on_rename_button_pressed():
	var neo_name = name_edit.text.strip_edges()
	if neo_name.is_empty():
		return

	if _selected_tree_item:
		var selected_node = _selected_tree_item.get_metadata(0)
		if selected_node["is_kernel"]:
			return
		selected_node["name"] = neo_name
		if _save_node(selected_node):
			_selected_tree_item.set_text(0, selected_node["name"])

func _on_remove_button_pressed():
	var dialog = PromisedConfirmationDialog.new()
	dialog.dialog_text = "Are you sure to remove category?"
	add_child(dialog)
	var should_delete = await dialog.prompt_user_to_make_decision()
	dialog.queue_free()

	if should_delete and _selected_tree_item:
		if _remove_node(_selected_node):
			_selected_tree_item.free()
			_selected_tree_item = null
