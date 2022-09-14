extends RefCounted
class_name PromisedHTTPResponse

var status_code := 200
var headers := PromisedHTTPHeaders.new()
var body: Variant = {}

func _init(p_status_code: int, p_headers: PackedStringArray, p_body: PackedByteArray) -> void:
	status_code = p_status_code
	headers = PromisedHTTPHeaders.from_string_array(p_headers)
	body = p_body
