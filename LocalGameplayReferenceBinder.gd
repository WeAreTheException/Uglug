extends Node
class_name LocalGameplayReferenceBinder

@export var match_network_root: MatchNetworkRoot
@export var deck_system_root: DeckSystemRoot
@export var placement_controller: PlacementController
@export var sacrifice_controller: SacrificeController
@export var sacrifice_board_binder: SacrificeBoardSelectionBinder


func _ready() -> void:
	_apply_local_refs()


func _apply_local_refs() -> void:
	if match_network_root == null or deck_system_root == null:
		return

	var owner := match_network_root.get_local_owner()
	var local_hand := deck_system_root.get_hand_for_owner(owner)

	if placement_controller != null:
		placement_controller.player_hand = local_hand
		placement_controller.set_active_owner(owner)

	if sacrifice_controller != null:
		sacrifice_controller.set_player_hand(local_hand)

	if sacrifice_board_binder != null:
		sacrifice_board_binder.player_hand = local_hand
		sacrifice_board_binder.allowed_owner = owner
