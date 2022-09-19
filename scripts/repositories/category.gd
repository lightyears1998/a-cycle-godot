extends EntryRepository
class_name CategoryRepository

const CATEGORY_TREE_ITEM_TEMPLATE := {
	"uid": "", # qualified name for kernel category or uuid for custom ones
	"parent": "", # empty string or uid of parent category
	"children": [], # Array of children uid
	"is_kernel": false,
	"entry": null, # Associated database entry, `null` for kernel categories
}

const CATEGORY_ENTRY_CONTENT_TYPE := "category"

const CATEGORY_ENTRY_CONTENT_TEMPLATE := {
	"uid": "", # qualified name for kernel category or uuid for custom ones
	"parent": null, # empty string or uid of parent category
	"name": "",
	"description": "",
}

var tree: Dictionary = {}

func create() -> Dictionary:
	var content = CATEGORY_ENTRY_CONTENT_TEMPLATE.duplicate(true)
	return super.fork(CATEGORY_ENTRY_CONTENT_TYPE, content)

func _find_all_custom_categories() -> Array[Dictionary]:
	return Database.Entry.select_rows("contentType='%s'" % CATEGORY_ENTRY_CONTENT_TYPE)

func _get_kenerl_categories() -> Array[Dictionary]:
	return [
		{
			"parent": null,
			"name": "category/kernel",
			"description": "Root category for all kernel categories."
		}, {
			"parent": null,
			"name": "category/kernel-resting"
		}
	]

func _build_tree():
	var customs = self._find_all_customs()
	var kernels =  self._get_kernels()

	tree = {}
	for category in categories:
		tree[category.uuid] = {
			"uid": category.uuid,
			"parent": category.parent,
			"children": [],
			"item": category,
		}
	for category in categories:
		if category["parent"] and category["parent"] in tree:
			tree[category["parent"]].children.append(category.uuid)

func get_tree() -> Dictionary:
	if tree.is_empty():
		_build_tree()

	return tree
