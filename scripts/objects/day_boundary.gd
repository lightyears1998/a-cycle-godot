extends RefCounted
class_name DayBoundary

const day_in_secs = 60 * 60 * 24

var lower_bound: int # unix_time
var upper_bound: int # unix_time

func _init(date: Datetime):
	self.lower_bound = date.get_the_beginning_of_the_day().to_unix_time()
	self.upper_bound = date.get_the_end_of_the_day().to_unix_time()
