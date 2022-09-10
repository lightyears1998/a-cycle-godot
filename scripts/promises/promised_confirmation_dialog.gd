extends ConfirmationDialog
class_name PromisedConfirmationDialog

signal decision_made

var _decision_ok: bool
var _decision_cancel: bool
var _decision_custom: String

func _reset():
	_decision_ok = false
	_decision_cancel = false
	_decision_custom = ""

func _ready() -> void:
	_reset()
	about_to_popup.connect(_on_about_to_popup)
	close_requested.connect(_on_close_requested)
	go_back_requested.connect(_on_go_back_requested)
	get_ok_button().pressed.connect(_on_decision_ok)
	get_cancel_button().pressed.connect(_on_decision_cancel)
	custom_action.connect(_on_decision_custom)

func prompt_user_to_make_decision() -> Variant:
	popup_centered()
	await decision_made
	if _decision_ok:
		return true
	elif _decision_cancel:
		return false
	elif _decision_custom:
		return _decision_custom
	return false

func _on_about_to_popup() -> void:
	_reset()

func _on_close_requested() -> void:
	decision_made.emit()

func _on_go_back_requested() -> void:
	decision_made.emit()

func _on_decision_ok() -> void:
	_decision_ok = true
	decision_made.emit()

func _on_decision_cancel() -> void:
	_decision_cancel = true
	decision_made.emit()

func _on_decision_custom(decision: String) -> void:
	_decision_custom = decision
	decision_made.emit()
	hide()
