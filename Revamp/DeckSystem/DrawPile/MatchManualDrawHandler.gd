extends Node
class_name MatchManualDrawHandler

@export var local_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
@export var print_debug: bool = true

var worker_button: BaseButton = null
var warrior_button: BaseButton = null
var deck_system_root: DeckSystemRoot = null


func setup(
	new_worker_button: BaseButton,
	new_warrior_button: BaseButton,
	new_deck_system_root: DeckSystemRoot
) -> void:
	_disconnect_buttons()

	worker_button = new_worker_button
	warrior_button = new_warrior_button
	deck_system_root = new_deck_system_root

	if worker_button != null:
		worker_button.pressed.connect(_on_worker_pressed)

	if warrior_button != null:
		warrior_button.pressed.connect(_on_warrior_pressed)


func _on_worker_pressed() -> void:
	_request_draw(DeckSystemRoot.DRAW_PILE_WORKER)


func _on_warrior_pressed() -> void:
	_request_draw(DeckSystemRoot.DRAW_PILE_WARRIOR)


func _request_draw(pile_type: String) -> void:
	if deck_system_root == null:
		print("MANUAL DRAW BLOCKED: DeckSystemRoot missing")
		return

	var network := deck_system_root.match_network_root

	if network != null:
		network.request_draw(
			network.get_local_owner(),
			pile_type,
			[]
		)
	else:
		_draw_locally(pile_type)

	if print_debug:
		print("MANUAL DRAW PRESSED: ", pile_type)


func _draw_locally(pile_type: String) -> void:
	if pile_type == DeckSystemRoot.DRAW_PILE_WORKER:
		deck_system_root.draw_worker_for_owner(local_owner)
	else:
		deck_system_root.draw_warrior_for_owner(local_owner)


func _disconnect_buttons() -> void:
	if (
		worker_button != null
		and worker_button.pressed.is_connected(
			_on_worker_pressed
		)
	):
		worker_button.pressed.disconnect(
			_on_worker_pressed
		)

	if (
		warrior_button != null
		and warrior_button.pressed.is_connected(
			_on_warrior_pressed
		)
	):
		warrior_button.pressed.disconnect(
			_on_warrior_pressed
		)
