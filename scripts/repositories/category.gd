extends EntryRepository
class_name CategoryRepository

const CATEGORY_TREE_ITEM_TEMPLATE := {
	"uid": "", # qualified name for kernel category or uuid for custom ones
	"parent_uid": "", # empty string or uid of parent category
	"children_uids": [], # Array of children uid
	"is_kernel": false,
	"name": "", # text
	"description": "", # text
	"entry": null, # Associated database entry, `null` for kernel categories
}

const CATEGORY_ENTRY_CONTENT_TYPE := "category"

const CATEGORY_ENTRY_CONTENT_TEMPLATE := {
	"uid": "", # qualified name for kernel category or uuid for custom ones
	"parentUid": "", # empty string or uid of parent category
	"name": "", # text
	"description": "", # text
}

var _tree: Dictionary = {}

func create() -> Dictionary:
	var content = CATEGORY_ENTRY_CONTENT_TEMPLATE.duplicate(true)
	return super.fork(CATEGORY_ENTRY_CONTENT_TYPE, content)

func _get_custom_categories_tree() -> Dictionary:
	var entries = super.select_rows("contentType='%s'" % CATEGORY_ENTRY_CONTENT_TYPE)
	var custom_tree = {}
	for entry in entries:
		var tree_item = {}
		var content = entry.content
		tree_item["uid"] = content["uid"]
		tree_item["parent_uid"] = content["parentUid"]
		tree_item["children_uids"] = []
		tree_item["is_kernel"] = false
		tree_item["name"] = content["name"]
		tree_item["description"] = content["description"]
		tree_item["entry"] = entry
		custom_tree[content["uid"]] = tree_item
	return custom_tree

func _build_kernel_category_tree_item(uid: String, parent_uid: String, name: String) -> Dictionary:
	var tree_item = CATEGORY_TREE_ITEM_TEMPLATE.duplicate(true)
	tree_item["uid"] = uid
	tree_item["parent_uid"] = parent_uid
	tree_item["is_kernel"] = true
	tree_item["name"] = name
	return tree_item

func _get_kenerl_categories_tree() -> Dictionary:
	var category_tree_items = [
		_build_kernel_category_tree_item("kernel", "", "Kernel"),
		_build_kernel_category_tree_item("kernel/dining", "kernel", "Dining"),
		_build_kernel_category_tree_item("kernel/sleeping", "kernel", "Sleeping"),
		_build_kernel_category_tree_item("kernel/sports", "kernel", "Sports"),
		_build_kernel_category_tree_item("kernel/grooming", "kernel", "Grooming"),
		_build_kernel_category_tree_item("kernel/sumarizing", "kernel", "Sumarizing"),
	]
	var kernel_tree = {}
	for item in category_tree_items:
		kernel_tree[item.uid] = item
		if not item["parent_uid"].is_empty():
			kernel_tree[item["parent_uid"]].children_uids.append(item.uid)
	return kernel_tree

func _build_tree():
	var kernel_tree = _get_kenerl_categories_tree()
	var custom_tree = _get_custom_categories_tree()
	_tree.merge(kernel_tree)
	_tree.merge(custom_tree)

func get_tree() -> Dictionary:
	if _tree.is_empty():
		_build_tree()
	return _tree

func save_tree_item(tree_item) -> bool:
	if tree_item["is_kernel"]:
		return false
	super.save(tree_item.entry)
	return true
