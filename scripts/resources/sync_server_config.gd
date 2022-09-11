extends Resource
class_name SyncServerConfig

@export var host := "127.0.0.1"
@export var http_port := 5280
@export var ws_port := 5281
@export var path := "api"
@export var username := ""
@export var password := "" # TODO storaging hash instead of plain text to protect privacy.
@export var use_tls := false

@export var user_id := ""
@export var token := ""

func get_restful_url() -> String:
	var schema = "https" if use_tls else "http"
	return schema + "://" + host + ":" + str(http_port) + "/" + path

func get_socket_url() -> String:
	var schema = "wss" if use_tls else "ws"
	return schema + "://" + host + ":" + str(ws_port) + "/" + path + '/socket'

func get_identifier() -> String:
	return "%s@%s" % [username, host]
