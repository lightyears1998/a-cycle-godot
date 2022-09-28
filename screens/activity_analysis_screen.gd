extends VBoxContainer

var datetime = Datetime.new()

var _activities = []

func _read_activities() -> void:
	_activities = ActivityRepository.find_by_start_date(datetime)
	_activities.sort_custom(func (a, b): return a.content.date < b.content.date)
