extends EntryRepository
class_name ActivityRepository

const ENTRY_CONTENT_TYPE := "activity"

const ACTIIVITY_CONTENT_TEMPLATE = {
	"title": "", # text
	"description": "", # text
	"category": [
		# category_uid
	],
	"startDate": 0, # unix_time
	"endDate": 0, # unix_time
	"isTransient": false,
	"metadata": {
		# Placeholder for future use.
	}
}

func create():
	pass
