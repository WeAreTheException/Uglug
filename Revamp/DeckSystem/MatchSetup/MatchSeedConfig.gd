extends Node
class_name MatchSeedConfig

signal seed_changed(seed_value: int)

@export var seed_value: int = 12345
@export var randomize_on_ready: bool = false


func _ready() -> void:
	if randomize_on_ready:
		randomize_seed()


func randomize_seed() -> int:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	seed_value = rng.randi()
	seed_changed.emit(seed_value)

	return seed_value


func set_seed(value: int) -> void:
	seed_value = value
	seed_changed.emit(seed_value)


func get_seed() -> int:
	return seed_value
