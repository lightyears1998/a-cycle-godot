extends RefCounted
class_name HTTPResponse

var status_code := 200
var headers := HTTPHeaders.new()
var body: Variant = {}

func _init(p_status_code: int, p_headers: PackedStringArray, p_body: PackedByteArray) -> void:
	status_code = p_status_code
	headers = HTTPHeaders.from_string_array(p_headers)
	body = p_body
