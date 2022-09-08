extends EntryEntity
class_name DiaryEntity

const DIARY_TEMPLATE = {
	"date": "unix_time",
	"title": "text",
	"content": "text",
}

func create():
	var diary = DIARY_TEMPLATE.duplicate(true)
	diary.date = Datetime.get_unix_time()

	var entry = super.create()
	entry.contentType = "diary"
	entry.content = diary

	return entry
