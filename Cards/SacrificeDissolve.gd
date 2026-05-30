extends Node
class_name SacrificeDissolve

@export var card_art_node_name: String = "CardArt"

@export var dissolve_shader: Shader

@export var dissolve_time: float = 0.6
@export var start_strength: float = 0.0
@export var end_strength: float = 1.0

@export var seed: float = 0.5
@export var direction: Vector2 = Vector2(-0.5, 0.0)
@export var mask_vignette_strength: float = 0.5
@export var mask_vignette_center: Vector2 = Vector2(0.5, 0.3)

@export var hide_card_when_done: bool = true

var active_materials: Array[ShaderMaterial] = []


func play(card: Card) -> void:
	if card == null:
		return

	if dissolve_shader == null:
		print("sacrifice dissolve blocked: dissolve_shader is null")
		return

	var card_art := card.find_child(card_art_node_name, true, false)

	if card_art == null:
		print("sacrifice dissolve blocked: could not find ", card_art_node_name)
		return

	var dissolve_targets := _get_drawable_nodes(card_art)

	if dissolve_targets.is_empty():
		print("sacrifice dissolve blocked: no drawable nodes found under ", card_art_node_name)
		return

	active_materials.clear()

	for target in dissolve_targets:
		var material := ShaderMaterial.new()
		material.shader = dissolve_shader

		material.set_shader_parameter("strength", start_strength)
		material.set_shader_parameter("seed", seed)
		material.set_shader_parameter("direction", direction)
		material.set_shader_parameter("mask_vignette_strength", mask_vignette_strength)
		material.set_shader_parameter("mask_vignette_center", mask_vignette_center)

		target.material = material
		active_materials.append(material)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_method(_set_strength, start_strength, end_strength, dissolve_time)

	await tween.finished

	if hide_card_when_done and is_instance_valid(card):
		card.visible = false


func _set_strength(value: float) -> void:
	for material in active_materials:
		if material != null:
			material.set_shader_parameter("strength", value)


func _get_drawable_nodes(root: Node) -> Array[CanvasItem]:
	var results: Array[CanvasItem] = []

	if root == null:
		return results

	for child in root.get_children():
		if child is Sprite2D:
			results.append(child as CanvasItem)
		elif child is TextureRect:
			results.append(child as CanvasItem)
		elif child is NinePatchRect:
			results.append(child as CanvasItem)
		elif child is Polygon2D:
			results.append(child as CanvasItem)

		results.append_array(_get_drawable_nodes(child))

	return results
