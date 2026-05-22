extends Node
class_name BackInHandCardState

@export var invert_material: ShaderMaterial

var card: Card = null
var is_enabled := false
var original_material: Material = null


func _ready() -> void:
	card = get_parent() as Card


func enable() -> void:
	if is_enabled:
		return

	is_enabled = true
	_apply_visual()


func disable() -> void:
	is_enabled = false
	_clear_visual()


func try_handle_death() -> bool:
	if not is_enabled:
		return false

	if card == null:
		return false

	var return_manager := get_tree().get_first_node_in_group("back_in_hand_return_manager") as BackInHandReturnManager

	if return_manager == null:
		print("BackInHandCardState blocked: no BackInHandReturnManager found")
		return false

	return_manager.return_card_to_hand(card)
	return true


func _apply_visual() -> void:
	var sprite := _get_card_sprite()
	if sprite == null:
		print("BackInHandCardState blocked: no card sprite found")
		return

	original_material = sprite.material

	if invert_material != null:
		sprite.material = invert_material.duplicate()


func _clear_visual() -> void:
	var sprite := _get_card_sprite()
	if sprite == null:
		return

	sprite.material = original_material


func _get_card_sprite() -> Sprite2D:
	if card == null:
		return null

	var stats := card.get_node_or_null("Stats")
	if stats != null:
		var sprite = stats.get("card_sprite")
		if sprite is Sprite2D:
			return sprite

	return card.find_child("Sprite2D", true, false) as Sprite2D
