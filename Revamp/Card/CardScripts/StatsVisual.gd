extends Node2D
class_name StatsVisuals

@export var attack: Sprite2D
@export var health: Sprite2D
@export var cost: Array[Sprite2D]
@export var name_label: RichTextLabel

@export var attack_textures: Array[Texture2D]
@export var health_textures: Array[Texture2D]

var stats: CardStats = null


func setup_from_stats(source_stats: CardStats, card_name: String) -> void:
	if source_stats == null:
		return

	stats = source_stats

	update_name(card_name)

	if not stats.attack_changed.is_connected(update_attack):
		stats.attack_changed.connect(update_attack)

	if not stats.health_changed.is_connected(update_health):
		stats.health_changed.connect(update_health)

	if not stats.cost_changed.is_connected(update_cost):
		stats.cost_changed.connect(update_cost)

	update_attack(stats.get_attack())
	update_health(stats.get_health())
	update_cost(stats.get_cost())


func update_name(value: String) -> void:
	if name_label == null:
		return

	name_label.text = value


func update_attack(value: int) -> void:
	if attack == null:
		return

	if value <= 0:
		attack.texture = null
		return

	var index := value - 1

	if index >= 0 and index < attack_textures.size():
		attack.texture = attack_textures[index]
	else:
		attack.texture = null


func update_health(value: int) -> void:
	if health == null:
		return

	if value <= 0:
		health.texture = null
		return

	var index := value - 1

	if index >= 0 and index < health_textures.size():
		health.texture = health_textures[index]
	else:
		health.texture = null


func update_cost(value: int) -> void:
	for i in range(cost.size()):
		if cost[i] == null:
			continue

		cost[i].visible = i < value
