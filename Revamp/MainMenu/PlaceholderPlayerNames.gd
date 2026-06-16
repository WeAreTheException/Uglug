extends RefCounted
class_name PlaceholderPlayerNames

const NAMES: Array[String] = [
	"Mao",
	"Sergio",
	"Trex",
	"Raashi",
	"David",
	"Kevin",
	"Taniha",
	"Seyam",
	"Patrick",
	"Kabir",
	"Pietro",
	"Tim",
	"Eva",
	"Olivia",
	"Gabe",
	"Ishaan",
	"Marion",
	"Stella"
]


static func get_name_for_id(id: int) -> String:
	if NAMES.is_empty():
		return "Player"

	var index: int = posmod(id, NAMES.size())
	return NAMES[index]


static func get_random_name() -> String:
	if NAMES.is_empty():
		return "Player"

	var index: int = randi_range(0, NAMES.size() - 1)
	return NAMES[index]
