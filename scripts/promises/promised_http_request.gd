extends HTTPRequest
class_name PromisedHTTPRequest

signal _request_async_completed_or_canceled

var last_client_error_code := OK
var last_result_error_code := RESULT_SUCCESS
var last_response: HTTPResponse

var _is_request_ongoing := false
var _is_canceled := false

func _ready():
	request_completed.connect(_on_request_completed)

static func client_error_string(client_error_code: int) -> String:
	return error_string(client_error_code)

static func result_error_string(result_error_code: int) -> String:
	match result_error_code:
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

class RequestAsyncResult:
	var client_error_code := OK
	var client_error_string: String
	var result_error_code := HTTPRequest.RESULT_SUCCESS
	var result_error_string: String
	var response: HTTPResponse

	func _init(
		p_client_error_code: int,
		p_result_error_code: int = HTTPRequest.RESULT_SUCCESS,
		p_response: HTTPResponse = null
	) -> void:
		client_error_code = p_client_error_code
		client_error_string = PromisedHTTPRequest.client_error_string(client_error_code)
		result_error_code = p_result_error_code
		result_error_string = PromisedHTTPRequest.result_error_string(result_error_code)
		response = p_response

	func is_errored() -> bool:
		return client_error_code != OK or result_error_code != HTTPRequest.RESULT_SUCCESS

	func get_error_string() -> String:
		if client_error_code != OK:
			return client_error_string
		elif result_error_code != HTTPRequest.RESULT_SUCCESS:
			return result_error_string
		return ""

func _prepare_request_data(request_headers: PackedStringArray, request_data: Variant) -> String:
	match typeof(request_data):
		TYPE_STRING:
			pass
		TYPE_DICTIONARY:
			# Convert Godot Dictionary to JSON object
			request_headers.append("Content-Type: application/json")
			request_data = JSON.stringify(request_data)
		_:
			request_data = var_to_str(request_data)
			Logcat.debug("Using fallback `var_to_str` method, which may lead to bugs.")
	return request_data

func cancel_request():
	super.cancel_request()
	_is_request_ongoing = false
	_is_canceled = true
	_request_async_completed_or_canceled.emit()

func request_async(
	url: String,
	custom_headers: PackedStringArray = PackedStringArray(),
	ssl_validate_domain: bool = true,
	method: HTTPClient.Method = HTTPClient.Method.METHOD_GET,
	request_data: Variant = ""
) -> RequestAsyncResult:
	if _is_request_ongoing:
		# If user make a new request when the previous request is ongoing,
		# cancel both the previous request and the new one.
		Logcat.panic("Making simultaneous requests under the same PromisedHTTPRequest node will corrupt their data and thus should be avoided.")
		self.cancel_request()
		return RequestAsyncResult.new(ERR_ALREADY_IN_USE)

	request_data = _prepare_request_data(custom_headers, request_data)

	Logcat.verbose("Request: " + url + " initializing.")
	var client_error_code = request(url, custom_headers, ssl_validate_domain, method, request_data)
	if client_error_code:
		last_client_error_code = client_error_code
		return RequestAsyncResult.new(client_error_code, 0, null)

	Logcat.verbose("Request: " + url + " ongoing.")
	_is_request_ongoing = true
	_is_canceled = false
	await _request_async_completed_or_canceled
	if _is_canceled:
		return RequestAsyncResult.new(ERR_SKIP)
	last_client_error_code = OK

	Logcat.verbose("Request: " + url + " done.")
	return RequestAsyncResult.new(last_client_error_code, last_result_error_code, last_response)

func _on_request_completed(result_error_code: int, status_code: int, headers: PackedStringArray, body: PackedByteArray):
	last_result_error_code = result_error_code
	last_response = HTTPResponse.new(status_code, headers, body)
	if last_result_error_code == HTTPRequest.RESULT_SUCCESS:
		_parse_content(last_response)
	_is_request_ongoing = false
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
