extends Area2D
class_name NewSlots

enum SlotOwner {
	PLAYER,
	OPPONENT
}

@export var lane_id: int = 0
@export var slot_owner: SlotOwner = SlotOwner.PLAYER
@export var opposing_slot: NewSlots

@export var slot_visual: CanvasItem

@export var damage_flash_color: Color = Color(1, 0, 0, 1)
@export var damage_flash_scale: Vector2 = Vector2(1.8, 1.8)
@export var damage_flash_time: float = 0.35

var current_card: Node2D = null

var _base_modulate: Color = Color.WHITE
var _base_scale: Vector2 = Vector2.ONE
var _flash_tween: Tween = null


func _ready() -> void:
	if slot_visual == null:
		slot_visual = get_node_or_null("SlotVisual") as CanvasItem

	if slot_visual != null:
		_base_modulate = slot_visual.modulate
		_base_scale = slot_visual.scale
	else:
		print("NewSlots warning: SlotVisual missing on ", name)


func is_empty() -> bool:
	return current_card == null


func can_accept_card(card: Node2D) -> bool:
	if card == null:
		return false

	var c := card as Card

	if c == null:
		return false

	if c.card_owner != slot_owner:
		print("wrong side")
		return false

	return current_card == null or current_card == card


func assign_card(card: Node2D) -> bool:
	if not can_accept_card(card):
		print("slot full")
		return false

	current_card = card

	if not card.is_in_group("cuttable_cards"):
		card.add_to_group("cuttable_cards")

	return true


func clear_card() -> void:
	if current_card != null:
		current_card.remove_from_group("cuttable_cards")

	current_card = null


func flash_damage() -> void:
	print("FLASH CALLED ON: ", name, " visual=", slot_visual)

	if slot_visual == null:
		print("flash failed: slot_visual null on ", name)
		return

	if _flash_tween != null:
		_flash_tween.kill()

	slot_visual.visible = true
	slot_visual.modulate = damage_flash_color
	slot_visual.scale = damage_flash_scale

	_flash_tween = create_tween()

	_flash_tween.tween_property(
		slot_visual,
		"scale",
		_base_scale,
		damage_flash_time
	)

	_flash_tween.parallel().tween_property(
		slot_visual,
		"modulate",
		_base_modulate,
		damage_flash_time
	)
