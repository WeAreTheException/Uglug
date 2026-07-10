extends Node2D
class_name CardVisualsRoot

@export var main_visuals: CardMainVisuals
@export var mutation_visuals: CardMutationVisuals
@export var stats_visual: StatsVisuals
@export var mutation_tooltip: MutationToolTip

@export var auto_show_mutation_tooltip_on_hover: bool = false

@export var viewport_sprite: Sprite2D
@export var revenant_overlay: Sprite2D
@export var revenant_shader: Shader

@export var draw_hide_cover: CanvasItem

var card: CardRoot = null
var revenant_material: ShaderMaterial = null


func setup_from_card(source_card: CardRoot) -> void:
	if source_card == null:
		return

	card = source_card

	setup_revenant_overlay()
	set_hidden_for_draw(false)
	_connect_mutation_visuals()

	if card.card_data != null:
		setup_from_card_data(card.card_data)

	if card.stats != null and stats_visual != null:
		stats_visual.setup_from_stats(card.stats, card.card_name)

	if card.mutations != null:
		if not card.mutations.mutations_changed.is_connected(_on_mutations_changed):
			card.mutations.mutations_changed.connect(_on_mutations_changed)

	_update_mutation_visuals()
	refresh_revenant_visual()


func setup_from_card_data(data: CardData) -> void:
	if data == null:
		return

	if main_visuals != null:
		main_visuals.set_ant_texture(data.ant_texture)
		main_visuals.set_background_texture(data.background_texture)


func refresh_all() -> void:
	if card == null:
		return

	if card.card_data != null:
		setup_from_card_data(card.card_data)

	if card.stats != null and stats_visual != null:
		stats_visual.setup_from_stats(card.stats, card.card_name)

	_update_mutation_visuals()
	refresh_revenant_visual()


func set_hidden_for_draw(value: bool) -> void:
	if draw_hide_cover == null:
		return

	draw_hide_cover.visible = value


func setup_revenant_overlay() -> void:
	if revenant_overlay == null:
		return

	revenant_overlay.visible = false

	if viewport_sprite != null:
		revenant_overlay.texture = viewport_sprite.texture

	if revenant_material != null:
		return

	if revenant_shader == null:
		return

	revenant_material = ShaderMaterial.new()
	revenant_material.shader = revenant_shader
	revenant_overlay.material = revenant_material


func apply_revenant_visual() -> void:
	if revenant_overlay == null:
		print("REVENANT VISUAL BLOCKED: overlay missing")
		return

	if viewport_sprite != null:
		revenant_overlay.texture = viewport_sprite.texture

	revenant_overlay.visible = true


func remove_revenant_visual() -> void:
	if revenant_overlay == null:
		return

	revenant_overlay.visible = false


func refresh_revenant_visual() -> void:
	if card == null:
		remove_revenant_visual()
		return

	if card.is_revenant():
		apply_revenant_visual()
	else:
		remove_revenant_visual()


func _connect_mutation_visuals() -> void:
	if mutation_visuals == null:
		return

	if not mutation_visuals.sigil_hovered.is_connected(_on_sigil_hovered):
		mutation_visuals.sigil_hovered.connect(_on_sigil_hovered)

	if not mutation_visuals.sigil_unhovered.is_connected(_on_sigil_unhovered):
		mutation_visuals.sigil_unhovered.connect(_on_sigil_unhovered)

	if not mutation_visuals.sigil_right_clicked.is_connected(_on_sigil_right_clicked):
		mutation_visuals.sigil_right_clicked.connect(_on_sigil_right_clicked)

	if not mutation_visuals.sigil_left_clicked.is_connected(_on_sigil_left_clicked):
		mutation_visuals.sigil_left_clicked.connect(_on_sigil_left_clicked)


func _on_sigil_hovered(slot: SigilSlot) -> void:
	if not auto_show_mutation_tooltip_on_hover:
		return

	if mutation_tooltip == null:
		return

	if slot == null:
		return

	mutation_tooltip.show_mutation(slot.get_mutation())


func _on_sigil_unhovered(_slot: SigilSlot) -> void:
	if mutation_tooltip == null:
		return

	mutation_tooltip.hide_tooltip()


func _on_sigil_right_clicked(slot: SigilSlot) -> void:
	if auto_show_mutation_tooltip_on_hover:
		return

	if mutation_tooltip == null:
		return

	if slot == null:
		return

	mutation_tooltip.show_mutation(slot.get_mutation())


func _on_sigil_left_clicked(_slot: SigilSlot) -> void:
	pass


func _on_mutations_changed() -> void:
	_update_mutation_visuals()


func _update_mutation_visuals() -> void:
	if mutation_visuals == null:
		return

	mutation_visuals.clear_all()

	if card == null:
		return

	if card.mutations == null:
		return

	mutation_visuals.display_runtimes(card.mutations.get_all_runtimes())
