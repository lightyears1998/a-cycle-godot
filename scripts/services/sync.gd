extends Node
class_name SyncService

@onready var http_request := PromisedHTTPRequest.new()

func _ready() -> void:
	add_child(http_request)

func _exit_tree() -> void:
	http_request.queue_free()

func get_user_id(config: SyncServerConfig) -> String:
	Logcat.info("Requesting user id for " + config.compose_identifier() + ".")

	var url = config.get_restful_url()
	url += '/users/?username=' + config.username.uri_encode()

	var result = await http_request.request_async(url)
	if not result.error:
		var payload = result.response.body["payload"]
		var user = payload["user"]
		var user_id = user["id"]
		config.user_id = user_id
		Logcat.info("Updated user id (" + str(config.user_id) + ") for " +  config.compose_identifier() + ".")
		return user_id
	else:
		Logcat.warn(var_to_str(result.error))

	return ""

func get_user_token(config: SyncServerConfig) -> String:
	Logcat.info("Requesting user token for " + config.compose_identifier() + ".")

	var url = config.get_restful_url()
	url += '/users/:userId/jwt-tokens'.replace(":userId", str(config.user_id))

	var result = await http_request.request_async(url, [], true, HTTPClient.METHOD_POST, {
		"passwordSha256": config.password.sha256_text()
	})
	if not result.error:
		var payload = result.response.body["payload"]
		var token = payload["token"]
		if token:
			Logcat.info("Accquired user token %s for " % token + config.compose_identifier() + ".")
			config.token = token
			return token
		else:
			Logcat.error("Failed to get user token.")
	else:
		Logcat.error(var_to_str(result.error))

	return ""

