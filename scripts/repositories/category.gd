extends EntryRepository
class_name CategoryRepository

const ENTRY_CONTENT_TYPE := "category"

const CATEGORY_CONTENT_TEMPLATE = {
	"name": "text",
	"parent": "category_uuid",
}

func create():
	var content = CATEGORY_CONTENT_TEMPLATE.duplicate(true)
	content["parent"] = "";
	return super.fork(ENTRY_CONTENT_TYPE, content)
