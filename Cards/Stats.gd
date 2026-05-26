extends Node2D
class_name Stats

@export var attack: Sprite2D
@export var health: Sprite2D
@export var cost: Array[Sprite2D]
@export var name_label: RichTextLabel

@export var attack_textures: Array[Texture2D]
@export var health_textures: Array[Texture2D]


func setup_from_card_data(data: CardData) -> void:
	if data == null:
		return

	update_name(data.name)
	update_attack(data.attack)
	update_health(data.health)
	update_cost(data.cost)


func update_name(value: String) -> void:
	if name_label == null:
		return

	name_label.text = value
	name_label.z_index = 100


func update_attack(value: int) -> void:
	if attack == null:
		return

	attack.z_index = 100
	attack.visible = true

	if value <= 0:
		attack.texture = null
		return

	var index: int = value - 1

	if index >= 0 and index < attack_textures.size():
		attack.texture = attack_textures[index]
	else:
		attack.texture = null


func update_health(value: int) -> void:
	if health == null:
		return

	health.z_index = 100
	health.visible = true

	if value <= 0:
		health.texture = null
		return

	var index: int = value - 1

	if index >= 0 and index < health_textures.size():
		health.texture = health_textures[index]
	else:
		health.texture = null


func update_cost(card_cost: int) -> void:
	for i in range(cost.size()):
		if cost[i] == null:
			continue

		cost[i].visible = i < card_cost
		cost[i].z_index = 100
