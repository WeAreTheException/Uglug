extends Node2D
class_name DominantRoot

@export var dominant_database: DominantDatabase
@export var dominant_index: int = 0

@export var round_manager: RoundManager
@export var phase_manager: PhaseManager

@export var player_hand: Node2D
@export var worker_deck: Node

@onready var state_handler: DominantStateHandler = get_node_or_null("DominantStateHandler")
@onready var sprite_handler: DominantSpriteHandler = get_node_or_null("DominantSpriteHandler")

var dominant: Dominant = null
var has_triggered_round_2_draw := false

var worker_union_buff_handler: WorkerUnionBuffHandler = null

func _ready() -> void:
	dominant = _get_dominant_from_database()

	if sprite_handler != null:
		sprite_handler.set_dominant(dominant)

	if round_manager == null:
		round_manager = _find_round_manager_recursive(get_tree().current_scene)

	if phase_manager == null:
		phase_manager = _find_phase_manager_recursive(get_tree().current_scene)

	if state_handler == null:
		print("DominantRoot blocked: DominantStateHandler not found")
		return

	if round_manager == null:
		print("DominantRoot blocked: RoundManager not found")
		return

	if phase_manager == null:
		print("DominantRoot blocked: PhaseManager not found")
		return

	_find_worker_union_handler()

	if not state_handler.state_changed.is_connected(_on_dominant_state_changed):
		state_handler.state_changed.connect(_on_dominant_state_changed)

	if not round_manager.round_changed.is_connected(_on_round_changed):
		round_manager.round_changed.connect(_on_round_changed)

	if not phase_manager.phase_changed.is_connected(_on_phase_changed):
		phase_manager.phase_changed.connect(_on_phase_changed)

	_apply_round_state(round_manager.current_round)

func _on_dominant_state_changed(_new_state: DominantStateHandler.DominantState) -> void:
	_update_worker_union_state()

func _on_round_changed(round_number: int) -> void:
	_apply_round_state(round_number)

func _on_phase_changed(phase_name: String) -> void:
	if phase_name != "Draw":
		return

	if dominant == null:
		return

	if round_manager == null:
		return

	if round_manager.current_round != 2:
		return

	if has_triggered_round_2_draw:
		return

	has_triggered_round_2_draw = true

	if dominant.has_method("on_round_draw_phase"):
		dominant.on_round_draw_phase(self, round_manager.current_round)

func _apply_round_state(round_number: int) -> void:
	if round_number <= 1:
		state_handler.set_state(DominantStateHandler.DominantState.DISABLED)
	else:
		state_handler.set_state(DominantStateHandler.DominantState.ACTIVE)

	_update_worker_union_state()

func _update_worker_union_state() -> void:
	if worker_union_buff_handler == null:
		return

	var active := false

	if dominant is WorkerUnionDominant:
		if state_handler.current_state == DominantStateHandler.DominantState.ACTIVE:
			active = true

	worker_union_buff_handler.set_worker_union_active(active)

func _find_worker_union_handler() -> void:
	if worker_deck == null:
		print("WorkerUnion blocked: worker_deck not assigned")
		return

	var draw_handler := _find_draw_handler_recursive(worker_deck)

	if draw_handler == null:
		print("WorkerUnion blocked: DeckDrawHandler not found in worker_deck")
		return

	worker_union_buff_handler = draw_handler.get_node_or_null("WorkerUnionBuffHandler") as WorkerUnionBuffHandler

	if worker_union_buff_handler == null:
		print("WorkerUnion blocked: WorkerUnionBuffHandler missing under DeckDrawHandler")
		return

	print("WorkerUnionBuffHandler linked")

func draw_worker_cards_from_dominant(amount: int) -> void:
	if amount <= 0:
		return

	if worker_deck == null:
		print("ExtraWorkerDominant blocked: worker_deck not assigned")
		return

	var draw_handler := _find_draw_handler_recursive(worker_deck)

	if draw_handler == null:
		print("ExtraWorkerDominant blocked: DeckDrawHandler not found in worker_deck")
		return

	var owner_peer_id := -1

	if GDSync != null:
		owner_peer_id = int(GDSync.get_client_id())

	if draw_handler.has_method("spawn_cards_from_effect"):
		print("ExtraWorkerDominant drawing worker cards: ", amount)
		draw_handler.spawn_cards_from_effect(owner_peer_id, amount)
	else:
		print("ExtraWorkerDominant blocked: DeckDrawHandler missing spawn_cards_from_effect")

func _get_dominant_from_database() -> Dominant:
	if dominant_database == null:
		print("DominantRoot blocked: dominant_database not assigned")
		return null

	var picked_dominant := dominant_database.get_dominant(dominant_index)

	if picked_dominant == null:
		print("DominantRoot blocked: no dominant found at index: ", dominant_index)
		return null

	print("DominantRoot loaded dominant: ", picked_dominant.dominant_name)

	return picked_dominant

func _find_draw_handler_recursive(node: Node) -> DeckDrawHandler:
	if node == null:
		return null

	if node is DeckDrawHandler:
		return node

	for child in node.get_children():
		var found := _find_draw_handler_recursive(child)
		if found != null:
			return found

	return null

func _find_round_manager_recursive(node: Node) -> RoundManager:
	if node == null:
		return null

	if node is RoundManager:
		return node

	for child in node.get_children():
		var found := _find_round_manager_recursive(child)
		if found != null:
			return found

	return null

func _find_phase_manager_recursive(node: Node) -> PhaseManager:
	if node == null:
		return null

	if node is PhaseManager:
		return node

	for child in node.get_children():
		var found := _find_phase_manager_recursive(child)
		if found != null:
			return found

	return null
