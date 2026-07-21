extends Node2D
class_name StatsVisuals

@export var attack: Sprite2D
@export var health: Sprite2D
@export var cost: Array[Sprite2D]
@export var name_label: RichTextLabel

@export var attack_label: RichTextLabel
@export var health_label: RichTextLabel
@export var cost_label: RichTextLabel

@export var attack_text_feedback: StatTextFeedback
@export var health_text_feedback: StatTextFeedback

@export var attack_textures: Array[Texture2D]
@export var health_textures: Array[Texture2D]

var stats: CardStats = null
var last_attack_value: int = 0
var last_health_value: int = 0
var has_attack_value: bool = false
var has_health_value: bool = false


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

	_set_attack_instant(stats.get_attack())
	_set_health_instant(stats.get_health())
	update_cost(stats.get_cost())


func update_name(value: String) -> void:
	if name_label == null:
		return

	name_label.text = value


func update_attack(value: int) -> void:
	if not has_attack_value:
		_set_attack_instant(value)
		return

	var old_value := last_attack_value
	last_attack_value = value

	if attack_text_feedback != null:
		attack_text_feedback.play_value_change(old_value, value)
		return

	if attack_label != null:
		attack_label.text = str(value)

	if attack != null:
		attack.visible = false


func update_health(value: int) -> void:
	if not has_health_value:
		_set_health_instant(value)
		return

	var old_value := last_health_value
	last_health_value = value

	if health_text_feedback != null:
		health_text_feedback.play_value_change(old_value, value)
		return

	if health_label != null:
		health_label.text = str(value)

	if health != null:
		health.visible = false


func update_cost(value: int) -> void:
	if cost_label != null:
		cost_label.text = str(value)

	_update_cost_sprites(value)


func _set_attack_instant(value: int) -> void:
	last_attack_value = value
	has_attack_value = true

	if attack_text_feedback != null:
		attack_text_feedback.set_value_instant(value)
	elif attack_label != null:
		attack_label.text = str(value)

	if attack != null:
		attack.visible = false


func _set_health_instant(value: int) -> void:
	last_health_value = value
	has_health_value = true

	if health_text_feedback != null:
		health_text_feedback.set_value_instant(value)
	elif health_label != null:
		health_label.text = str(value)

	if health != null:
		health.visible = false


func _update_cost_sprites(value: int) -> void:
	var visible_count := clampi(value, 0, cost.size())

	for i in range(cost.size()):
		if cost[i] == null:
			continue

		cost[i].visible = i < visible_count
