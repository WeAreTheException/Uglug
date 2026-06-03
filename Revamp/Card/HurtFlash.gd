extends Node
class_name HurtFlash

@export var visuals_root: Node
@export var flash_time: float = 0.05
@export var flash_color: Color = Color(1, 0.5, 0.5, 1)

var original_modulates: Dictionary = {}


func play(card: CardRoot) -> void:
	var root := visuals_root

	if root == null and card != null:
		root = card.get_node_or_null("Visuals")

	if root == null:
		return

	_apply_flash(root)

	await get_tree().create_timer(flash_time).timeout

	_clear_flash()


func _apply_flash(root: Node) -> void:
	original_modulates.clear()

	var visuals := _get_visual_nodes(root)

	for visual in visuals:
		original_modulates[visual] = visual.modulate
		visual.modulate = flash_color


func _clear_flash() -> void:
	for visual in original_modulates.keys():
		if is_instance_valid(visual):
			visual.modulate = original_modulates[visual]

	original_modulates.clear()


func _get_visual_nodes(root: Node) -> Array[CanvasItem]:
	var results: Array[CanvasItem] = []

	if root == null:
		return results

	for child in root.get_children():
		if child is CanvasItem:
			results.append(child as CanvasItem)

		results.append_array(_get_visual_nodes(child))

	return results
