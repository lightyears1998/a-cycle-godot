extends VBoxContainer
class_name CategoryPicker

signal category_changed(category: Dictionary)

var selected_category:
	get:
		return _selected_category
	set(value):
		_selected_category = value
		if select_or_confirm_button and category_tree:
			_update_ui()

@onready var selected_category_name_label = %SelectedCategoryNameLabel as Label
@onready var select_or_confirm_button = %SelectOrConfirmButton as Button
@onready var category_tree = %CategoryTree as CategoryTree

var _selected_category = null
var _expanded_for_selection = false

func select_by_category_uids(uids: Array):
	var uid = uids.front() if len(uids) > 0 else null
	if category_tree and uid in category_tree._map:
		selected_category = category_tree._map[uid]
	else:
		selected_category = null

func _update_ui():
	category_tree.visible = _expanded_for_selection
	if _expanded_for_selection:
		select_or_confirm_button.text = "Confirm"
	else:
		select_or_confirm_button.text = "Select"
	if selected_category:
		selected_category_name_label.text = selected_category.name
	else:
		selected_category_name_label.text = "(Not Selected)"

func _ready():
	_update_ui()

func _on_category_tree_category_selected(category_node):
	selected_category = category_node
	_update_ui()

func _on_select_or_confirm_button_pressed():
	if _expanded_for_selection:
		selected_category = category_tree._selected_node
		category_changed.emit(selected_category)
	_expanded_for_selection = !_expanded_for_selection
	_update_ui()

func _on_clear_button_pressed():
	selected_category = null
	_expanded_for_selection = false
	_update_ui()
	category_changed.emit(selected_category)
