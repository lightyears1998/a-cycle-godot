extends EntryRepository
class_name ActivityRepository

const ENTRY_CONTENT_TYPE := "activity"

const ACTIIVITY_CONTENT_TEMPLATE = {
	"title": "text",
	"description": "text",
	"category": [
		"category_fully_qualified_name_or_uuid"
	],
	"startDate": "unix_time",
	"endDate": "unix_time",
	"isTransient": false,
	"metadata": {
		# Placeholder for future use.
	}
}

func create():
	pass
