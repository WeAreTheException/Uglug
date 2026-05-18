extends Node2D
class_name MutationInstance

@export var sprite: Sprite2D

@export_group("Tooltip")
@export var tooltip_scene: PackedScene
@export var tooltip_offset: Vector2 = Vector2(0, -100)
@export var hover_size: Vector2 = Vector2(300, 300)

var mutation: Mutation = null
var target_hand: NewPlayerHand = null
var phase_manager: PhaseManager = null
var used: bool = false

var tooltip_instance: Control = null
var tooltip_name_label: Label = null
var tooltip_description_label: Label = null

var mouse_inside := false


func _ready() -> void:
	print("MUTATION INSTANCE READY: ", get_path())

	if sprite == null:
		sprite = get_node_or_null("Sprite2D") as Sprite2D

	phase_manager = get_tree().current_scene.find_child("PhaseManager", true, false) as PhaseManager

	if phase_manager != null:
		if not phase_manager.phase_changed.is_connected(_on_phase_changed):
			phase_manager.phase_changed.connect(_on_phase_changed)

	_create_tooltip()
	_hide_tooltip()

	set_process(true)


func _process(_delta: float) -> void:
	var now_inside := _is_mouse_over_instance()

	if now_inside and not mouse_inside:
		mouse_inside = true
		print("BUFF TOOLTIP HOVER ENTERED")
		_show_tooltip()

	if not now_inside and mouse_inside:
		mouse_inside = false
		print("BUFF TOOLTIP HOVER EXITED")
		_hide_tooltip()

	if mouse_inside and tooltip_instance != null:
		tooltip_instance.global_position = global_position + tooltip_offset


func setup_mutation(new_mutation: Mutation, new_target_hand: NewPlayerHand = null) -> void:
	mutation = new_mutation
	target_hand = new_target_hand

	if sprite == null:
		sprite = get_node_or_null("Sprite2D") as Sprite2D

	if mutation == null:
		print("MutationInstance blocked: mutation is null")
		return

	if sprite == null:
		print("MutationInstance blocked: Sprite2D missing")
		return

	if mutation.sigil_texture == null:
		print("MutationInstance blocked: mutation sigil_texture is null")
		return

	sprite.texture = mutation.sigil_texture
	sprite.visible = true

	_update_tooltip_text()

	print("MutationInstance setup complete: ", mutation)


func _is_mouse_over_instance() -> bool:
	if sprite == null:
		return false

	var mouse_pos := get_global_mouse_position()
	var local_mouse := sprite.to_local(mouse_pos)

	var size := hover_size

	if sprite.texture != null:
		size = sprite.texture.get_size()

	if size.x < hover_size.x:
		size.x = hover_size.x

	if size.y < hover_size.y:
		size.y = hover_size.y

	var rect := Rect2(-size * 0.5, size)

	return rect.has_point(local_mouse)


func _create_tooltip() -> void:
	if tooltip_scene == null:
		print("TOOLTIP FAILED: tooltip_scene is null. Assign it on MutationInstance scene.")
		return

	tooltip_instance = tooltip_scene.instantiate() as Control

	if tooltip_instance == null:
		print("TOOLTIP FAILED: tooltip_scene root is not Control.")
		return

	get_tree().current_scene.add_child(tooltip_instance)

	tooltip_instance.visible = false
	tooltip_instance.z_index = 9999
	tooltip_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE

	tooltip_name_label = tooltip_instance.find_child("NameLabel", true, false) as Label
	tooltip_description_label = tooltip_instance.find_child("DescriptionLabel", true, false) as Label

	print("TOOLTIP CREATED: ", tooltip_instance)
	print("NameLabel found: ", tooltip_name_label)
	print("DescriptionLabel found: ", tooltip_description_label)

	_update_tooltip_text()


func _update_tooltip_text() -> void:
	var title := "Mutation"
	var desc := ""

	if mutation != null:
		if "mutation_name" in mutation and mutation.mutation_name != "":
			title = mutation.mutation_name

		if "mutation_description" in mutation:
			desc = mutation.mutation_description
		
		elif "description" in mutation:
			desc = mutation.description

	if tooltip_name_label != null:
		tooltip_name_label.text = title

	if tooltip_description_label != null:
		tooltip_description_label.text = desc


func _show_tooltip() -> void:
	print("SHOW TOOLTIP CALLED")

	if tooltip_instance == null:
		print("SHOW TOOLTIP FAILED: tooltip_instance is null")
		return

	_update_tooltip_text()

	tooltip_instance.global_position = global_position + tooltip_offset
	tooltip_instance.visible = true
	tooltip_instance.z_index = 9999

	print("TOOLTIP VISIBLE AT: ", tooltip_instance.global_position)


func _hide_tooltip() -> void:
	if tooltip_instance != null:
		tooltip_instance.visible = false


func _on_phase_changed(phase_name: String) -> void:
	if used:
		return

	if phase_name == "Buff":
		return

	auto_apply_to_random_card()


func auto_apply_to_random_card() -> void:
	if used:
		return

	if mutation == null:
		print("auto buff blocked: mutation is null")
		queue_free()
		return

	var target_card := get_auto_target_card()

	if target_card == null:
		print("auto buff blocked: no selected card and no cards in hand")
		queue_free()
		return

	used = true

	var board_manager := get_tree().current_scene.find_child("BoardManager", true, false) as BoardManager

	if board_manager != null:
		board_manager.request_add_mutation_to_card(target_card, mutation)
	else:
		target_card.add_additional_mutation(mutation)

	queue_free()


func get_auto_target_card() -> Card:
	var selected_card := SelectHandler.selected_card

	if selected_card != null:
		if selected_card.card_owner == Card.Owner.PLAYER and selected_card.current_slot == null:
			return selected_card

	if target_hand == null:
		print("auto buff warning: target_hand is null")
		return null

	return target_hand.get_random_card()


func _exit_tree() -> void:
	if is_instance_valid(tooltip_instance):
		tooltip_instance.queue_free()
