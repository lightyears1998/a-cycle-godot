extends Control

@onready var result_edit = %ResultEdit as CodeEdit
@onready var req = %PromisedHTTPRequest as PromisedHTTPRequest

func _print_result(result):
	if result.error:
		result_edit.text = error_string(result.error)
	else:
		var completed = result.completed
		result_edit.text = completed.result_string
		result_edit.text += '\n' + str(completed.response_code)
		result_edit.text += '\n' + var_to_str(completed.headers)
		result_edit.text += '\n' + completed.body.get_string_from_utf8()

func _on_get_example_dot_com_button_pressed() -> void:
	var result = await req.request_async("http://example.com")
	_print_result(result)
