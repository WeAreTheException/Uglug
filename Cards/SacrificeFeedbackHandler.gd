extends Node
class_name SacrificeFeedbackHandler

@export var debug_enabled: bool = true

@export var sacrifice_anim: SacrificeAnim
@export var sacrifice_sprite: SacrificeSprite
@export var sacrifice_burn: SacrificeBurn
@export var sacrifice_dissolve: SacrificeDissolve
@export var sacrifice_audio: SacrificeAudio

var card: Card = null
var is_burning: bool = false


func _ready() -> void:
	card = _find_card_parent()

	if sacrifice_anim == null:
		sacrifice_anim = get_node_or_null("SacrificeAnim") as SacrificeAnim

	if sacrifice_sprite == null:
		sacrifice_sprite = get_node_or_null("SacrificeSprite") as SacrificeSprite

	if sacrifice_burn == null:
		sacrifice_burn = get_node_or_null("SacrificeBurn") as SacrificeBurn

	if sacrifice_dissolve == null:
		sacrifice_dissolve = get_node_or_null("SacrificeDissolve") as SacrificeDissolve

	if sacrifice_audio == null:
		sacrifice_audio = get_node_or_null("SacrificeAudio") as SacrificeAudio


func _unhandled_input(event: InputEvent) -> void:
	if not debug_enabled:
		return
	if card == null:
		return
	if is_burning:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_K:
				show_sacrifice_ready()

			KEY_L:
				show_sacrifice_hovered()

			KEY_SEMICOLON:
				show_sacrifice_selected()

			KEY_APOSTROPHE:
				await play_sacrifice_burn()


func show_sacrifice_ready() -> void:
	if sacrifice_anim != null:
		sacrifice_anim.start_wiggle(card)


func show_sacrifice_hovered() -> void:
	if sacrifice_sprite != null:
		sacrifice_sprite.show_hovered(card)


func show_sacrifice_selected() -> void:
	if sacrifice_sprite != null:
		sacrifice_sprite.show_selected(card)


func play_sacrifice_burn() -> void:
	if card == null:
		return

	is_burning = true

	if sacrifice_anim != null:
		sacrifice_anim.stop_wiggle(card)

	if sacrifice_sprite != null:
		sacrifice_sprite.hide_sprite()

	if sacrifice_audio != null:
		sacrifice_audio.play()

	if sacrifice_burn != null:
		await sacrifice_burn.play(card)

	if sacrifice_dissolve != null:
		await sacrifice_dissolve.play(card)

	is_burning = false


func clear_sacrifice_feedback() -> void:
	if sacrifice_anim != null:
		sacrifice_anim.stop_wiggle(card)

	if sacrifice_sprite != null:
		sacrifice_sprite.hide_sprite()


func _find_card_parent() -> Card:
	var current := get_parent()

	while current != null:
		if current is Card:
			return current as Card

		current = current.get_parent()

	return null
