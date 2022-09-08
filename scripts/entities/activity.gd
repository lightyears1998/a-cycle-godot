extends RefCounted
class_name ActivityEntity

const ACTIIVITY_TEMPLATE = {
	"title": "text",
	"description": "text",
	"category": [
		"category_id"
	],
	"startDate": "unix_time",
	"endDate": "unix_time",
	"isTransient": false,
	"metadata": {}
}

func create():
	pass
