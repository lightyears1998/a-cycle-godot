extends EntryRepository
class_name TodoItemRepository

const TODO_ITEM_CONTENT_TYPE := "todo_item"

const TODO_ITEM_CONTENT_TEMPLATE = {
	"title": "text",
	"description": "text",
	"category": [
		"category_fully_qualified_name_or_uuid"
	],
	"startDate": "unix_time",
	"endDate": "unix_time",
	"doneDate": "unix_time",
	"isTransient": false,
	"repeat": "", # "by-week"
	"metadata": {
		# Placeholder for future use.
	}
}

func create() -> Dictionary:
	var content = TODO_ITEM_CONTENT_TEMPLATE.duplicate(true)
	return super.fork(TODO_ITEM_CONTENT_TYPE, content)
