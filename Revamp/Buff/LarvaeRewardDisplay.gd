extends Node2D
class_name LarvaeRewardDisplay

@export var name_label: RichTextLabel
@export var sigil_sprite: Sprite2D
@export var larvae_sprite: Sprite2D

@export var default_font_size: int = 18
@export var medium_font_size: int = 14
@export var small_font_size: int = 11

@export var test_mutation: Mutation
@export var run_debug_test_on_ready: bool = false

var mutation: Mutation = null


func _ready() -> void:
	if name_label != null:
		name_label.bbcode_enabled = true

	if run_debug_test_on_ready:
		setup_from_mutation(test_mutation)


func setup_from_mutation(new_mutation: Mutation) -> void:
	mutation = new_mutation

	if mutation == null:
		_clear()
		return

	_set_name_text(_get_larvae_name())

	if sigil_sprite != null:
		sigil_sprite.texture = mutation.sigil_texture
		sigil_sprite.visible = mutation.sigil_texture != null

	print("LarvaeRewardDisplay setup: ", _get_larvae_name())


func get_mutation() -> Mutation:
	return mutation


func _set_name_text(value: String) -> void:
	if name_label == null:
		return

	var font_size := default_font_size

	if value.length() > 16:
		font_size = medium_font_size

	if value.length() > 22:
		font_size = small_font_size

	name_label.text = (
		"[center][font_size="
		+ str(font_size)
		+ "]"
		+ value
		+ "[/font_size][/center]"
	)


func _get_larvae_name() -> String:
	if mutation == null:
		return "Larvae"

	if mutation.mutation_name.strip_edges() == "":
		return "Larvae"

	return mutation.mutation_name + " Larvae"


func _clear() -> void:
	_set_name_text("Larvae")

	if sigil_sprite != null:
		sigil_sprite.texture = null
		sigil_sprite.visible = false
