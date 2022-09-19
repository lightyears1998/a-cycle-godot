extends EntryRepository
class_name CategoryRepository

const ENTRY_CONTENT_TYPE := "category"

const CATEGORY_TREE_ITEM_TEMPLATE := {
	"uid": "", # qualified name for kernel category or uuid for custom ones
	"parent": "", # empty string or uid of parent category
	"children": [], # Array of children uid
	"entry": null, # Associated database entry
}

const CATEGORY_CONTENT_TEMPLATE := {
	"parent": null,
	"name": "",
	"description": "",
}

var tree: Dictionary = {}

func create() -> Dictionary:
	var content = CATEGORY_CONTENT_TEMPLATE.duplicate(true)
	return super.fork(ENTRY_CONTENT_TYPE, content)

func _find_all_customs() -> Array[Dictionary]:
	return Database.Entry.select_rows("contentType='%s'" % ENTRY_CONTENT_TYPE)

func _get_kenerls() -> Array[Dictionary]:
	return [
#		{ "uuid": "", "c" }
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
