extends EntryRepository
class_name CategoryRepository

const CATEGORY_ENTRY_CONTENT_TYPE := "category"

const CATEGORY_ENTRY_CONTENT_TEMPLATE := {
	"uid": "", # qualified name for kernel category or uuid for custom ones
	"parentUid": "", # empty string or uid of parent category
	"name": "", # text
	"description": "", # text
}

func create() -> Dictionary:
	var content = CATEGORY_ENTRY_CONTENT_TEMPLATE.duplicate(true)
	return super.fork(CATEGORY_ENTRY_CONTENT_TYPE, content)

func list() -> Array[Dictionary]:
	return super.select_rows("contentType='%s'" % CATEGORY_ENTRY_CONTENT_TYPE)
