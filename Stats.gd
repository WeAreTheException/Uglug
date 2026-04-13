extends Node2D
class_name Stats

@export var card_sprite: Sprite2D
@export var cost: Array[Sprite2D]

func setup_from_card_data(data: CardData) -> void:
	if data == null:
		return

	update_sprite(data.sprite)
	update_cost(data.cost)

func update_sprite(texture: Texture2D) -> void:
	if card_sprite == null:
		return

	card_sprite.texture = texture

func update_cost(card_cost: int) -> void:
	for i in range(cost.size()):
		if cost[i] == null:
			continue

		cost[i].visible = i < card_cost
