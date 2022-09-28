extends "res://scripts/repositories/entry.gd"

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

func find_by_start_date(date: Datetime, discard_removed := true) -> Array[Dictionary]:
	var lower_bound = date.get_the_beginning_of_the_day().to_unix_time()
	var upper_bound = date.get_the_end_of_the_day().to_unix_time()
	var activities = super.select_rows("contentType='%s'" % ACTIIVITY_ENTRY_CONTENT_TYPE, discard_removed)
	activities = activities.filter(func (activity): return activity.content["startDate"] >= lower_bound and activity.content["startDate"] <= upper_bound)
	return activities
