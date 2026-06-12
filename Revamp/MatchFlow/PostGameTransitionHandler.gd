extends Node
class_name PostGameTransitionHandler

@export var match_flow_root: MatchFlowRoot
@export_file("*.tscn") var post_game_scene_path: String = ""

@export var wait_before_transition: float = 2.0
@export var print_debug: bool = true

var has_started: bool = false


func _ready() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_ended.is_connected(_on_match_ended):
		match_flow_root.match_ended.connect(_on_match_ended)


func _on_match_ended(
	winner: SlotRow.SlotOwner,
	final_score: int
) -> void:
	if has_started:
		return

	has_started = true

	if print_debug:
		print(
			"POST GAME TRANSITION STARTED | WINNER: ",
			_get_owner_name(winner),
			" | SCORE: ",
			final_score
		)

	await get_tree().create_timer(wait_before_transition).timeout

	_go_to_post_game_scene()


func _go_to_post_game_scene() -> void:
	if post_game_scene_path == "":
		print("post game transition blocked: scene path missing")
		return

	get_tree().change_scene_to_file(post_game_scene_path)


func _get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"
