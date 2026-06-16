extends Control
class_name MatchUIRoot

@export var match_flow_root: MatchFlowRoot
@export var slots_root: SlotsRoot
@export var score_state: MatchScoreState

@export var tugga_display: TuggaBattleScaleDisplay
@export var attack_order_arrow_display: AttackOrderArrowDisplay

@export var player_name_label: Label
@export var enemy_name_label: Label

@export var name_outline_size: int = 4
@export var print_name_debug: bool = false


func _ready() -> void:
	_resolve_score_state()
	_setup_children()
	_setup_name_labels()
	call_deferred("_setup_name_labels")


func setup_match_context(
	source_match_flow_root: MatchFlowRoot,
	source_slots_root: SlotsRoot
) -> void:
	match_flow_root = source_match_flow_root
	slots_root = source_slots_root

	_resolve_score_state()
	_setup_children()
	_setup_name_labels()


func _resolve_score_state() -> void:
	if score_state != null:
		return

	if match_flow_root == null:
		return

	score_state = match_flow_root.score_state


func _setup_children() -> void:
	if tugga_display != null:
		tugga_display.setup(score_state)

	if attack_order_arrow_display != null:
		attack_order_arrow_display.setup(
			slots_root,
			_get_turn_order_state()
		)


func _setup_name_labels() -> void:
	_apply_name_label_style(player_name_label)
	_apply_name_label_style(enemy_name_label)

	var local_client_id: int = _get_local_client_id()
	var enemy_client_id: int = _get_enemy_client_id(local_client_id)

	var local_name: String = _get_client_display_name(local_client_id)
	var enemy_name: String = _get_client_display_name(enemy_client_id)

	if player_name_label != null:
		player_name_label.text = local_name

	if enemy_name_label != null:
		enemy_name_label.text = enemy_name

	if print_name_debug:
		print("MATCH UI LOCAL ID: ", local_client_id, " NAME: ", local_name)
		print("MATCH UI ENEMY ID: ", enemy_client_id, " NAME: ", enemy_name)


func _apply_name_label_style(label: Label) -> void:
	if label == null:
		return

	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", name_outline_size)


func _get_local_client_id() -> int:
	var raw_id := str(GDSync.get_client_id())

	if raw_id.is_valid_int():
		return raw_id.to_int()

	return abs(raw_id.hash())


func _get_enemy_client_id(local_client_id: int) -> int:
	var clients: Array = GDSync.lobby_get_all_clients()

	for client in clients:
		var client_id: int = _client_to_int(client)

		if client_id != local_client_id:
			return client_id

	return -1


func _client_to_int(client) -> int:
	var raw_id := str(client)

	if raw_id.is_valid_int():
		return raw_id.to_int()

	return abs(raw_id.hash())


func _get_client_display_name(client_id: int) -> String:
	if client_id < 0:
		return "Enemy"

	var fallback_name := PlaceholderPlayerNames.get_name_for_id(client_id)

	return GDSync.player_get_username(client_id, fallback_name)


func _get_turn_order_state() -> MatchTurnOrderState:
	if match_flow_root == null:
		return null

	return match_flow_root.turn_order_state
