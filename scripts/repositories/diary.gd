extends "res://scripts/repositories/entry.gd"

const ENTRY_CONTENT_TYPE := "diary"

const DIARY_TEMPLATE = {
	"date": "unix_time",
	"title": "text",
	"content": "text",
}

func create(date: int = 0, title: String = "", content: String = "") -> Dictionary:
	var diary = DIARY_TEMPLATE.duplicate(true)
	diary.date = date
	diary.title = title
	diary.content = content
	var entry = super.create()
	entry["contentType"] = ENTRY_CONTENT_TYPE
	entry.content = diary
	return entry

func find_by_date(date: Datetime, discard_removed := true) -> Array[Dictionary]:
	var lower_bound = date.get_the_beginning_of_the_day().to_unix_time()
	var upper_bound = date.get_the_end_of_the_day().to_unix_time()
	var diaries = super.select_rows("contentType='%s'" % ENTRY_CONTENT_TYPE, discard_removed)
	diaries = diaries.filter(func (diary): return diary.content.date >= lower_bound and diary.content.date <= upper_bound)
	return diaries
