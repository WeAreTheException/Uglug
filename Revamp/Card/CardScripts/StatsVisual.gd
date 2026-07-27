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


func setup_from_stats(
	source_stats: CardStats,
	card_name: String
) -> void:
	if source_stats == null:
		return

	stats = source_stats

	update_name(card_name)

	if not stats.stat_display_changed.is_connected(
		_on_stat_display_changed
	):
		stats.stat_display_changed.connect(
			_on_stat_display_changed
		)

	if not stats.cost_changed.is_connected(update_cost):
		stats.cost_changed.connect(update_cost)

	_set_attack_instant(
		stats.get_attack(),
		stats.get_stat_modifier_state("attack")
	)

	_set_health_instant(
		stats.get_health(),
		stats.get_stat_modifier_state("health")
	)

	update_cost(stats.get_cost())


func update_name(value: String) -> void:
	if name_label == null:
		return

	name_label.text = value


func update_attack(value: int) -> void:
	var modifier_state := CardStats.CHANGE_NEUTRAL

	if stats != null:
		modifier_state = stats.get_stat_modifier_state(
			"attack"
		)

	_update_attack_with_context(
		value,
		CardStats.CHANGE_NEUTRAL,
		modifier_state
	)


func update_health(value: int) -> void:
	var modifier_state := CardStats.CHANGE_NEUTRAL

	if stats != null:
		modifier_state = stats.get_stat_modifier_state(
			"health"
		)

	_update_health_with_context(
		value,
		CardStats.CHANGE_NEUTRAL,
		modifier_state
	)


func update_cost(value: int) -> void:
	if cost_label != null:
		cost_label.text = str(value)

	_update_cost_sprites(value)


func _on_stat_display_changed(
	stat_name: String,
	value: int,
	change_type: String,
	modifier_state: String
) -> void:
	match stat_name:
		"attack":
			_update_attack_with_context(
				value,
				change_type,
				modifier_state
			)

		"health":
			_update_health_with_context(
				value,
				change_type,
				modifier_state
			)


func _update_attack_with_context(
	value: int,
	change_type: String,
	modifier_state: String
) -> void:
	if not has_attack_value:
		_set_attack_instant(
			value,
			modifier_state
		)
		return

	var old_value := last_attack_value
	last_attack_value = value

	if attack_text_feedback != null:
		attack_text_feedback.play_value_change_with_context(
			old_value,
			value,
			change_type,
			modifier_state
		)
		return

	if attack_label != null:
		attack_label.text = str(value)

	if attack != null:
		attack.visible = false


func _update_health_with_context(
	value: int,
	change_type: String,
	modifier_state: String
) -> void:
	if not has_health_value:
		_set_health_instant(
			value,
			modifier_state
		)
		return

	var old_value := last_health_value
	last_health_value = value

	if health_text_feedback != null:
		health_text_feedback.play_value_change_with_context(
			old_value,
			value,
			change_type,
			modifier_state
		)
		return

	if health_label != null:
		health_label.text = str(value)

	if health != null:
		health.visible = false


func _set_attack_instant(
	value: int,
	modifier_state: String
) -> void:
	last_attack_value = value
	has_attack_value = true

	if attack_text_feedback != null:
		attack_text_feedback.set_value_instant(
			value,
			modifier_state
		)
	elif attack_label != null:
		attack_label.text = str(value)

	if attack != null:
		attack.visible = false


func _set_health_instant(
	value: int,
	modifier_state: String
) -> void:
	last_health_value = value
	has_health_value = true

	if health_text_feedback != null:
		health_text_feedback.set_value_instant(
			value,
			modifier_state
		)
	elif health_label != null:
		health_label.text = str(value)

	if health != null:
		health.visible = false


func _update_cost_sprites(value: int) -> void:
	var visible_count := clampi(
		value,
		0,
		cost.size()
	)

	for i in range(cost.size()):
		if cost[i] == null:
			continue

		cost[i].visible = i < visible_count
