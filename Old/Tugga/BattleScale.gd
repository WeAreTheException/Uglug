extends Node
class_name BattleScale

signal scale_changed(value: int)

@export var win_value: int = 5
@export_file("*.tscn") var win_scene_path: String
@export_file("*.tscn") var lose_scene_path: String

var current_value: int = 0
var game_ended: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if game_ended:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_W:
				trigger_win()
			KEY_L:
				trigger_lose()

func add_direct_damage(amount: int, owner: int) -> void:
	if game_ended:
		return

	if owner == Card.Owner.PLAYER:
		current_value += amount
	elif owner == Card.Owner.OPPONENT:
		current_value -= amount

	current_value = clamp(current_value, -win_value, win_value)

	scale_changed.emit(current_value)

	print("scale: ", current_value)

	if current_value >= win_value:
		trigger_win()
	elif current_value <= -win_value:
		trigger_lose()

func trigger_win() -> void:
	if game_ended:
		return

	game_ended = true
	print("you win")
	go_to_scene(win_scene_path)

func trigger_lose() -> void:
	if game_ended:
		return

	game_ended = true
	print("you lose")
	go_to_scene(lose_scene_path)

func go_to_scene(scene_path: String) -> void:
	if scene_path == "":
		print("No scene path assigned")
		return

	get_tree().change_scene_to_file(scene_path)
