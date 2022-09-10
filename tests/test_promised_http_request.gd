extends Control

@onready var result_edit = %ResultEdit as CodeEdit
@onready var req = %PromisedHTTPRequest as PromisedHTTPRequest

func _clear_result():
	result_edit.text = "Requesting..."

func _print_result(result):
	if result.error:
		result_edit.text = error_string(result.error)
	else:
		var response = result.response
		result_edit.text = response.result_string
		result_edit.text += '\n' + str(response.response_code)
		result_edit.text += '\n' + var_to_str(response.headers)
		result_edit.text += '\n' + str(response.body)

func _on_cancel_request_button_pressed() -> void:
	req.cancel_request()

func _on_get_example_dot_com_button_pressed() -> void:
	_clear_result()
	var result = await req.request_async("http://example.com")
	_print_result(result)

func _on_request_json_button_pressed() -> void:
	_clear_result()
	var result = await req.request_async("https://httpbin.org/get")
	_print_result(result)
