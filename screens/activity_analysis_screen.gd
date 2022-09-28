extends VBoxContainer

var ActivityRepo = Database.Activity

var datetime = Datetime.new()

var _activities = []

func _read_activities() -> void:
	_activities = ActivityRepo.find_by_start_date(datetime)
	_activities.sort_custom(func (a, b): return a.content.date < b.content.date)
