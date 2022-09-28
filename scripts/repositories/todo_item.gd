extends "res://scripts/repositories/entry.gd"

const TODO_ITEM_ENTRY_CONTENT_TYPE := "todo_item"

const TODO_ITEM_ENTRY_CONTENT_TEMPLATE = {
	"title": "", # text
	"description": "", # text
	"category": [
		# category-uid
	],
	"startDate": 0, # unix_time
	"endDate": 0, # unix_time
	"doneDate": 0, # unix_time
	"isTransient": false,
	"repeat": "", # by-week
	"metadata": {
		# Placeholder for future use.
	}
}

func create() -> Dictionary:
	var content = TODO_ITEM_ENTRY_CONTENT_TEMPLATE.duplicate(true)
	return super.fork(TODO_ITEM_ENTRY_CONTENT_TYPE, content)
