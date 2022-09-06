extends Node

# see: <https://en.wikipedia.org/wiki/Universally_unique_identifier>
func uuidv4() -> String:
	var rand_4hex = func() -> int:
		return randi_range(0, (1 << 16) - 1)
	return "%04x%04x-%04x-%04x-%04x-%04x%04x%04x" % [
		rand_4hex.call(), 
		rand_4hex.call(),
		rand_4hex.call(),
		(rand_4hex.call() & 0x0fff) | 0x4000,
		(rand_4hex.call() & 0x3fff) | 0x8000,
		rand_4hex.call(),
		rand_4hex.call(),
		rand_4hex.call(),
	]
