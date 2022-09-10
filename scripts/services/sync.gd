extends Node
class_name SyncService

@onready var http_request := PromisedHTTPRequest.new()

func _ready() -> void:
	add_child(http_request)

func _exit_tree() -> void:
	http_request.queue_free()

func prepare_sync(config: SyncServerConfig) -> void:
	Logcat.info(config.get_identifier() + " Preparing Sync.")
	if config.user_id.is_empty():
		await get_user_id(config)
	if config.token.is_empty():
		await get_user_token(config)
	Logcat.info(config.get_identifier() + " Preparation finished.")

func get_user_id(config: SyncServerConfig) -> String:
	Logcat.info(config.get_identifier() + " Requesting user id...")

	var url = config.get_restful_url()
	url += '/users/?username=' + config.username.uri_encode()

	var result = await http_request.request_async(url)
	if result.is_errored():
		Logcat.error(result.get_error_string())
		return ""
	var response = result.response

	var errors = response.body["errors"]
	if errors:
		Logcat.warn(str(errors))
		return ""

	var payload = response.body["payload"]
	var user = payload["user"]
	var user_id = user["id"]
	config.user_id = user_id
	Logcat.info(config.get_identifier() + " Updated user id: %s." % str(config.user_id))
	return user_id

func get_user_token(config: SyncServerConfig) -> String:
	Logcat.info(config.get_identifier() + " Requesting user token for %s." % config.user_id)

	var url = config.get_restful_url()
	url += '/users/:userId/jwt-tokens'.replace(":userId", str(config.user_id))

	var result = await http_request.request_async(url, [], true, HTTPClient.METHOD_POST, {
		"passwordSha256": config.password.sha256_text()
	})
	if result.is_errored():
		Logcat.error(result.get_error_string())
		return ""
	var response = result.response

	var errors = response.body['errors']
	if errors:
		Logcat.error(str(errors))
		return ""

	var payload = response.body["payload"]
	var token = payload["token"]
	if token == null or token == "":
		Logcat.error("Failed to get user token.")
		return ""

	Logcat.info(config.get_identifier() + " Accquired user token %s for %s." % [token, config.user_id])
	config.token = token
	return token
