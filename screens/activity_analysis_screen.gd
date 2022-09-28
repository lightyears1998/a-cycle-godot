extends VBoxContainer

var datetime = Datetime.new()

@onready var time_progress_label = %TimeProgressLabel as Label
@onready var summary_container = %SummaryContainer as GridContainer

var _activities = []

func _ready() -> void:
	_read_activities()
	_update_ui()

func _update_ui() -> void:
	time_progress_label.text = "%.2f%%" % (_get_time_progress() * 100)
	_make_summary()

func _read_activities() -> void:
	_activities = ActivityRepository.find_by_date(datetime)

func _get_time_progress() -> float:
	var progress_in_secs = Datetime.new().to_unix_time() - datetime.get_the_beginning_of_the_day().to_unix_time()
	var porgress_percentage = float(progress_in_secs) / Datetime.DAY_IN_SECONDS
	porgress_percentage = clampf(porgress_percentage, 0., 1.)
	return porgress_percentage

func _make_summary() -> void:
	var summary := {}
	for activity in _activities:
		var category_name_or_uid = activity.content.categories.front() if len(activity.content.categories) > 0 else "(No Category)"
		var category_entry = CategoryRepository.find_by_category_uid(category_name_or_uid)
		var category_name = category_entry.content.name if category_entry else category_name_or_uid
		var timespan = activity.content["endDate"] - activity.content["startDate"]
		if category_name not in summary:
			summary[category_name] = 0
		summary[category_name] += timespan
	var keys = summary.keys()
	keys.sort()
	for key in keys:
		var timespan = float(summary[key])
		var name_label = Label.new()
		name_label.text = key
		var hour_label = Label.new()
		hour_label.text = "%.2fhr" % (timespan / Datetime.HOUR_IN_SECONDS)
		var percentage_label = Label.new()
		percentage_label.text = "%.2f%%" % (timespan / Datetime.DAY_IN_SECONDS * 100)
		summary_container.add_child(name_label)
		summary_container.add_child(hour_label)
		summary_container.add_child(percentage_label)
