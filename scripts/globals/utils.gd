extends Node
class_name UtilsSingleton

## Return the nil/empty uuid string.
const UUID_NIL := "00000000-0000-0000-0000-000000000000"

## Generate a randome uuidv4 string.
## see: <https://en.wikipedia.org/wiki/Universally_unique_identifier>
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

## Check if a given string is an uuid.
## It is a weak checker, but should be enough in our use case.
func is_uuid(candidate: String) -> bool:
	return len(candidate) == len(UUID_NIL)
