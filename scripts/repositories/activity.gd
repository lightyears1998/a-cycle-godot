extends EntryRepository
class_name ActivityRepository

const ACTIIVITY_ENTRY_CONTENT_TYPE := "activity"

const ACTIIVITY_ENTRY_CONTENT_TEMPLATE = {
	"title": "", # text
	"description": "", # text
	"categories": [
		# category_uid
	],
	"startDate": 0, # unix_time
	"endDate": 0, # unix_time
	"isTransient": false,
	"metadata": {
		# Placeholder for future use.
	}
}

func create() -> Dictionary:
	var content = ACTIIVITY_ENTRY_CONTENT_TEMPLATE.duplicate(true)
	return super.fork(ACTIIVITY_ENTRY_CONTENT_TYPE, content)
