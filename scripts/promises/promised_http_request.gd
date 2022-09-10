extends HTTPRequest
class_name PromisedHTTPRequest

signal _request_async_completed

var _request_async_result: RequestAsyncCompletedResult

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

class RequestAsyncCompletedResult:
	var result := HTTPRequest.Result.RESULT_SUCCESS
	var result_string := PromisedHTTPRequest.result_string(HTTPRequest.Result.RESULT_SUCCESS)
	var response_code := 200
	var headers := PackedStringArray()
	var body := PackedByteArray()

	func _init(p_result: HTTPRequest.Result, p_response_code: int, p_headers: PackedStringArray, p_body: PackedByteArray) -> void:
		result = p_result
		result_string = PromisedHTTPRequest.result_string(p_result)
		response_code = p_response_code
		headers = p_headers
		body = p_body

class RequestAsyncResult:
	var error := OK
	var completed: RequestAsyncCompletedResult

	func _init(p_error: int, p_completed: RequestAsyncCompletedResult = null) -> void:
		error = p_error
		completed = p_completed

## Wrap `request` method and `request_completed` singal
func request_async(
	url: String,
	custom_headers: PackedStringArray = PackedStringArray(),
	ssl_validate_domain: bool = true,
	method: HTTPClient.Method = 0,
	request_data: String = ""
) -> RequestAsyncResult:
	var error = request(url, custom_headers, ssl_validate_domain, method, request_data)
	if error:
		return RequestAsyncResult.new(error, null)
	await _request_async_completed
	return RequestAsyncResult.new(OK, _request_async_result)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	_request_async_result = RequestAsyncCompletedResult.new(result, response_code, headers, body)
	_request_async_completed.emit()
