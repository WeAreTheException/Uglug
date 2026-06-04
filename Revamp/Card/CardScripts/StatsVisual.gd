extends Node2D
class_name StatsVisuals

@export var attack: Sprite2D
@export var health: Sprite2D
@export var cost: Array[Sprite2D]
@export var name_label: RichTextLabel

@export var attack_textures: Array[Texture2D]
@export var health_textures: Array[Texture2D]

@export var animate_stat_changes: bool = true
@export var pop_scale: float = 1.35
@export var pop_up_time: float = 0.08
@export var pop_down_time: float = 0.10

var stats: CardStats = null
var has_initialized_visuals := false

var attack_tween: Tween = null
var health_tween: Tween = null

var attack_original_scale: Vector2 = Vector2.ONE
var health_original_scale: Vector2 = Vector2.ONE


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

	if attack != null:
		attack_original_scale = attack.scale

	if health != null:
		health_original_scale = health.scale

	has_initialized_visuals = false

	update_attack(stats.get_attack())
	update_health(stats.get_health())
	update_cost(stats.get_cost())

	has_initialized_visuals = true


func update_name(value: String) -> void:
	if name_label == null:
		return

	name_label.text = value


func update_attack(_value: int) -> void:
	if stats == null:
		return

	var new_texture: Texture2D = _get_texture_for_value(stats.get_attack(), attack_textures)

	_set_stat_with_pop(
		attack,
		new_texture,
		attack_original_scale,
		attack_tween,
		_apply_live_attack_texture
	)


func update_health(_value: int) -> void:
	if stats == null:
		return

	var new_texture: Texture2D = _get_texture_for_value(stats.get_health(), health_textures)

	_set_stat_with_pop(
		health,
		new_texture,
		health_original_scale,
		health_tween,
		_apply_live_health_texture
	)


func update_cost(value: int) -> void:
	for i in range(cost.size()):
		if cost[i] == null:
			continue

		cost[i].visible = i < value


func _set_stat_with_pop(
	sprite: Sprite2D,
	new_texture: Texture2D,
	original_scale: Vector2,
	current_tween: Tween,
	swap_callback: Callable
) -> void:
	if sprite == null:
		return

	if current_tween != null and current_tween.is_valid():
		current_tween.kill()

	sprite.scale = original_scale

	if not animate_stat_changes or not has_initialized_visuals:
		sprite.texture = new_texture
		return

	if sprite.texture == new_texture:
		return

	var new_tween := StatPopAnimator.play(
		self,
		sprite,
		original_scale,
		pop_scale,
		pop_up_time,
		pop_down_time,
		swap_callback
	)

	if sprite == attack:
		attack_tween = new_tween
	elif sprite == health:
		health_tween = new_tween


func _apply_live_attack_texture() -> void:
	if attack == null or stats == null:
		return

	attack.texture = _get_texture_for_value(stats.get_attack(), attack_textures)


func _apply_live_health_texture() -> void:
	if health == null or stats == null:
		return

	health.texture = _get_texture_for_value(stats.get_health(), health_textures)


func _get_texture_for_value(value: int, textures: Array[Texture2D]) -> Texture2D:
	if value <= 0:
		return null

	var index: int = value - 1

	if index >= 0 and index < textures.size():
		return textures[index]

	return null
