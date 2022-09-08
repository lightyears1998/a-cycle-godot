extends EntryRepository
class_name DiaryRepository

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
	entry.contentType = "diary"
	entry.content = diary

	return entry
