extends Node
class_name MatchDominantRevealHandler

signal dominant_reveal_started
signal dominant_reveal_finished

@export var match_flow_root: MatchFlowRoot
@export var print_debug: bool = true

var has_revealed_this_match: bool = false


func _ready() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	if state != MatchFlowRoot.MatchState.DOMINANT_REVEAL:
		return

	begin_dominant_reveal()


func begin_dominant_reveal() -> void:
	if has_revealed_this_match:
		if print_debug:
			print("DOMINANT REVEAL SKIPPED: already revealed")
		return

	has_revealed_this_match = true

	if print_debug:
		print("DOMINANT REVEAL STARTED: placeholder")

	dominant_reveal_started.emit()

	finish_dominant_reveal()


func finish_dominant_reveal() -> void:
	if print_debug:
		print("DOMINANT REVEAL FINISHED: placeholder")

	dominant_reveal_finished.emit()
