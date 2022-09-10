extends HTTPRequest
class_name PromisedHTTPRequest

signal _request_async_completed_or_canceled

var _is_making_request := false
var _http_response: HTTPResponse

func _ready():
	request_completed.connect(_on_request_completed)

## Returns a human-readable name for the given error result code.
static func result_string(result: int) -> String:
	match result:
		RESULT_SUCCESS: return "RESULT_SUCCESS"
		RESULT_CHUNKED_BODY_SIZE_MISMATCH: return "RESULT_CHUNKED_BODY_SIZE_MISMATCH"
		RESULT_CANT_CONNECT: return "RESULT_CANT_CONNECT"
		RESULT_CANT_RESOLVE: return "RESULT_CANT_RESOLVE"
		RESULT_CONNECTION_ERROR: return "RESULT_CONNECTION_ERROR"
		RESULT_SSL_HANDSHAKE_ERROR: return "RESULT_SSL_HANDSHAKE_ERROR"
		RESULT_NO_RESPONSE: return "RESULT_NO_RESPONSE"
		RESULT_BODY_SIZE_LIMIT_EXCEEDED: return "RESULT_BODY_SIZE_LIMIT_EXCEEDED"
		RESULT_BODY_DECOMPRESS_FAILED: return "RESULT_BODY_DECOMPRESS_FAILED"
		RESULT_REQUEST_FAILED: return "RESULT_REQUEST_FAILED"
		RESULT_DOWNLOAD_FILE_CANT_OPEN: return "RESULT_DOWNLOAD_FILE_CANT_OPEN"
		RESULT_DOWNLOAD_FILE_WRITE_ERROR: return "RESULT_DOWNLOAD_FILE_WRITE_ERROR"
		RESULT_REDIRECT_LIMIT_REACHED: return "RESULT_REDIRECT_LIMIT_REACHED"
		RESULT_TIMEOUT: return "RESULT_TIMEOUT"
	return ""

class HTTPHeaders:
	var _headers := {}

	static func from_headers_string_array(headers: PackedStringArray):
		var neo = HTTPHeaders.new()
		for header in headers:
			var kv = header.split(':', false, 1)
			if len(kv) == 2:
				neo._headers[str(kv[0]).to_lower()] = str(kv[1]).strip_edges()
		return neo

	func get_header(name: String) -> String:
		return _headers.get(name.to_lower())

	func _to_string() -> String:
		return str(_headers)

class HTTPResponse:
	var result := HTTPRequest.Result.RESULT_SUCCESS
	var result_string := PromisedHTTPRequest.result_string(HTTPRequest.Result.RESULT_SUCCESS)
	var response_code := 200
	var headers := HTTPHeaders.new()
	var body: Variant = {}

	func _init(p_result: HTTPRequest.Result, p_response_code: int, p_headers: PackedStringArray, p_body: PackedByteArray) -> void:
		result = p_result
		result_string = PromisedHTTPRequest.result_string(p_result)
		response_code = p_response_code
		headers = HTTPHeaders.from_headers_string_array(p_headers)
		body = p_body

class RequestAsyncResult:
	var error := OK
	var response: HTTPResponse

	func _init(p_error: int, p_response: HTTPResponse = null) -> void:
		error = p_error
		response = p_response

var last_error := OK
var last_response: HTTPResponse = HTTPResponse.new(OK, 200, [], [])

## Wrap `request` method and `request_completed` singal
func request_async(
	url: String,
	custom_headers: PackedStringArray = PackedStringArray(),
	ssl_validate_domain: bool = true,
	method: HTTPClient.Method = HTTPClient.Method.METHOD_GET,
	request_data: Variant = ""
) -> RequestAsyncResult:
	if _is_making_request:
		cancel_request()

	match typeof(request_data):
		TYPE_STRING:
			pass
		TYPE_DICTIONARY:
			request_data = JSON.stringify(request_data)
		_:
			request_data = var_to_str(request_data)

	var error = request(url, custom_headers, ssl_validate_domain, method, request_data)
	if error:
		return RequestAsyncResult.new(error, null)

	await _request_async_completed_or_canceled

	last_error = OK
	last_response = _http_response
	return RequestAsyncResult.new(OK, _http_response)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	_http_response = HTTPResponse.new(result, response_code, headers, body)
	_parse_content(_http_response)
	_is_making_request = false
	_request_async_completed_or_canceled.emit()

func _parse_content(http_response: HTTPResponse):
	var content_type = str(http_response.headers.get_header('content-type')).to_lower()

	if http_response.body is PackedByteArray:
		var is_utf8 = 'utf-8' in content_type or 'utf8' in content_type
		var is_ascii = 'ascii' in content_type or 'latin1' in content_type
		if is_utf8:
			http_response.body = http_response.body.get_string_from_utf8()
		elif is_ascii:
			http_response.body = http_response.body.get_string_from_ascii()
		else:
			http_response.body = http_response.body.get_string_from_utf8()

	if 'json' in content_type:
		var parsed_body = JSON.parse_string(http_response.body)
		http_response.body = parsed_body
