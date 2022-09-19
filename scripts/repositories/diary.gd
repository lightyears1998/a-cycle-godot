extends EntryRepository
class_name DiaryRepository

const DIARY_ENTRY_CONTENT_TYPE := "diary"

const DIARY_ENTRY_CONTENT_TEMPLATE = {
	"date": 0, # unix_time
	"title": "", # text
	"content": "", # text
}

func create(date: int = 0, title: String = "", content: String = "") -> Dictionary:
	var diary = DIARY_ENTRY_CONTENT_TEMPLATE.duplicate(true)
	diary.date = date
	diary.title = title
	diary.content = content
	return super.fork(DIARY_ENTRY_CONTENT_TYPE, diary)

func find_by_date(date: Datetime, discard_removed := true) -> Array[Dictionary]:
	var lower_bound = date.get_the_beginning_of_the_day().to_unix_time()
	var upper_bound = date.get_the_end_of_the_day().to_unix_time()
	var diaries = super.select_rows("contentType='%s'" % DIARY_ENTRY_CONTENT_TYPE, discard_removed)
	diaries = diaries.filter(func (diary): return diary.content.date >= lower_bound and diary.content.date <= upper_bound)
	return diaries
