extends RefCounted
class_name HTTPHeaders

var _headers := {}

static func from_string_array(headers: PackedStringArray):
	var http_headers = HTTPHeaders.new()
	for header in headers:
		var kv_pair = header.split(':', false, 1)
		if len(kv_pair) == 2:
			http_headers._headers[str(kv_pair[0]).to_lower()] = str(kv_pair[1]).strip_edges()
	return http_headers

func _to_string() -> String:
	return str(_headers)

func _to_formal_header_name(header_name: String) -> String:
	var formal_header_name = header_name
	formal_header_name[0] = formal_header_name[0].to_upper()
	for i in range(1, len(formal_header_name)):
		if formal_header_name[i - 1] == "-":
			formal_header_name[i] = formal_header_name[i].to_upper()
	return formal_header_name

func to_string_array() -> PackedStringArray:
	var array = PackedStringArray()
	for header_name in _headers.keys():
		var formal_header_name = _to_formal_header_name(header_name)
		var header_value = _headers[header_name]
		array.append("%s: %s" % [formal_header_name, header_value])
	return array

func get_header(header_name: String) -> String:
	return _headers.get(header_name.to_lower())

func set_header(header_name: String, header_value: String) -> void:
	_headers[header_name.to_lower()] = header_value
