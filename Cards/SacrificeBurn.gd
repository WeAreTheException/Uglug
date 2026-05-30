extends Node
class_name SacrificeBurn

@export var card_art_node_name: String = "CardArt"

@export var burn_shader: Shader
@export var noise_texture: Texture2D

@export var burn_time: float = 0.6
@export var start_radius: float = 0.0
@export var end_radius: float = 1.5

@export var burn_center: Vector2 = Vector2(0.5, 0.5)
@export var border_width: float = 0.02
@export var burn_mult: float = 0.135
@export var burn_color: Color = Color.BLACK

var active_materials: Array[ShaderMaterial] = []


func play(card: Card) -> void:
	if card == null:
		return

	if burn_shader == null:
		print("sacrifice burn blocked: burn_shader is null")
		return

	var card_art := card.find_child(card_art_node_name, true, false)

	if card_art == null:
		print("sacrifice burn blocked: could not find ", card_art_node_name)
		return

	var burn_targets := _get_drawable_nodes(card_art)

	if burn_targets.is_empty():
		print("sacrifice burn blocked: no drawable nodes found under ", card_art_node_name)
		return

	active_materials.clear()

	for target in burn_targets:
		var material := ShaderMaterial.new()
		material.shader = burn_shader

		material.set_shader_parameter("position", burn_center)
		material.set_shader_parameter("radius", start_radius)
		material.set_shader_parameter("borderWidth", border_width)
		material.set_shader_parameter("burnMult", burn_mult)
		material.set_shader_parameter("burnColor", burn_color)

		if noise_texture != null:
			material.set_shader_parameter("noiseTexture", noise_texture)

		target.material = material
		active_materials.append(material)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_method(_set_radius, start_radius, end_radius, burn_time)

	await tween.finished


func _set_radius(value: float) -> void:
	for material in active_materials:
		if material != null:
			material.set_shader_parameter("radius", value)


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
