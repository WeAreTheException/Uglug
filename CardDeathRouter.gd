extends Node
class_name CardDeathRouter

@export var normal_death_handler: Node


func _ready() -> void:
	add_to_group("card_death_router")


func kill_card(card: Node2D) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	var back_in_hand_manager := get_tree().get_first_node_in_group("back_in_hand_return_manager") as BackInHandReturnManager

	if back_in_hand_manager != null:
		if back_in_hand_manager.should_return_to_hand(card):
			back_in_hand_manager.return_card_to_hand(card)
			return

	if normal_death_handler != null and normal_death_handler.has_method("kill_card"):
		normal_death_handler.kill_card(card)
		return

	if normal_death_handler != null and normal_death_handler.has_method("handle_death"):
		normal_death_handler.handle_death(card)
		return

	print("CardDeathRouter fallback death: ", card.name)
	card.queue_free()
