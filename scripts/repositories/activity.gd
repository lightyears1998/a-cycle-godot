extends "res://scripts/repositories/entry.gd"

const ACTIIVITY_ENTRY_CONTENT_TYPE := "activity"

const ACTIIVITY_ENTRY_CONTENT_TEMPLATE := {
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

func _find_filter_and_sort(discard_removed := true, filter = func (): return true) -> Array[Dictionary]:
	var activities = super.select_rows("contentType='%s'" % ACTIIVITY_ENTRY_CONTENT_TYPE, discard_removed)
	activities = activities.filter(filter)
	activities.sort_custom(func (a, b): return a.content["startDate"] < b.content["startDate"])
	return activities

func find_by_start_date(date: Datetime, discard_removed := true) -> Array[Dictionary]:
	var boundary = DayBoundary.new(date)
	var filter = func (activity):
		return activity.content["startDate"] >= boundary.lower_bound and activity.content["startDate"] <= boundary.upper_bound
	return _find_filter_and_sort(discard_removed, filter)

func find_by_end_date(date: Datetime, discard_removed := true) -> Array[Dictionary]:
	var boundary = DayBoundary.new(date)
	var filter = func (activity):
		return activity.content["endDate"] >= boundary.lower_bound and activity.content["endDate"] <= boundary.upper_bound
	return _find_filter_and_sort(discard_removed, filter)

func find_by_date(date: Datetime, discard_removed := true):
	var boundary = DayBoundary.new(date)
	var filter = func (activity):
		return activity.content["endDate"] >= boundary.lower_bound and activity.content["startDate"] <= boundary.upper_bound
	return _find_filter_and_sort(discard_removed, filter)
