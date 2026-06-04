extends RefCounted
class_name HandCardFactoryHelper


func create_card(
	card_scene: PackedScene,
	data: CardData,
	parent: Node2D
) -> CardRoot:
	if card_scene == null:
		return null

	if data == null:
		return null

	var card := card_scene.instantiate() as CardRoot

	if card == null:
		push_error("HandCardFactoryHelper blocked: card_scene root is not CardRoot.")
		return null

	if parent != null:
		parent.add_child(card)
		card.global_position = parent.global_position

	card.setup(data)

	return card
