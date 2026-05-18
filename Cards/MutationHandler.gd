extends Node
class_name MutationHandler

var card: Card = null
var base_sigil_sprites: Array[Sprite2D] = []
var additional_sigil_sprites: Array[Sprite2D] = []


func _ready() -> void:
	card = get_parent() as Card

	if card == null:
		print("MutationHandler blocked: parent is not Card")
		return

	cache_sigil_nodes()
	hide_all_sigils()


func setup_from_card_data(data: CardData) -> void:
	if card == null:
		card = get_parent() as Card

	if card == null:
		return

	if data == null:
		return

	card.base_mutations = data.base_mutations.duplicate()
	card.additional_mutations = []

	print("=== MUTATION SETUP FOR ", data.name, " ===")
	print("base mutations: ", card.base_mutations.size())

	call_deferred("update_sigils")


func cache_sigil_nodes() -> void:
	base_sigil_sprites.clear()
	additional_sigil_sprites.clear()

	if card == null:
		return

	if card.base_sigil_container == null:
		print("base_sigil_container is null on ", card.card_name)
	else:
		var found_base := card.base_sigil_container.find_children("*", "Sprite2D", true, false)

		for node in found_base:
			var sprite := node as Sprite2D
			if sprite != null:
				base_sigil_sprites.append(sprite)

	if card.additional_sigil_container == null:
		print("additional_sigil_container is null on ", card.card_name)
	else:
		var found_additional := card.additional_sigil_container.find_children("*", "Sprite2D", true, false)

		for node in found_additional:
			var sprite := node as Sprite2D
			if sprite != null:
				additional_sigil_sprites.append(sprite)

	print("cached base sigil sprites: ", base_sigil_sprites.size())
	print("cached additional sigil sprites: ", additional_sigil_sprites.size())

func hide_all_sigils() -> void:
	for sprite in base_sigil_sprites:
		if is_instance_valid(sprite):
			sprite.visible = false

	for sprite in additional_sigil_sprites:
		if is_instance_valid(sprite):
			sprite.visible = false


func add_additional_mutation(mutation: Mutation) -> void:
	if card == null:
		return

	if mutation == null:
		return

	card.additional_mutations.append(mutation)
	update_sigils()

	print(card.card_name, " gained mutation")


func add_additional_mutation_from_path(mutation_path: String) -> void:
	if mutation_path == "":
		return

	var mutation := load(mutation_path) as Mutation

	if mutation == null:
		print("add mutation blocked: could not load ", mutation_path)
		return

	add_additional_mutation(mutation)


func get_additional_mutation_paths() -> Array[String]:
	var paths: Array[String] = []

	if card == null:
		return paths

	for mutation in card.additional_mutations:
		if mutation == null:
			continue

		if mutation.resource_path == "":
			continue

		paths.append(mutation.resource_path)

	return paths


func get_all_mutations() -> Array[Mutation]:
	var combined: Array[Mutation] = []

	if card == null:
		return combined

	for mutation in card.base_mutations:
		if mutation != null:
			combined.append(mutation)

	for mutation in card.additional_mutations:
		if mutation != null:
			combined.append(mutation)

	return combined


func update_sigils() -> void:
	if card == null:
		card = get_parent() as Card

	if card == null:
		return

	cache_sigil_nodes()

	print("=== UPDATE SIGILS FOR ", card.card_name, " ===")
	print("base mutations: ", card.base_mutations.size())
	print("base slots: ", base_sigil_sprites.size())
	print("additional mutations: ", card.additional_mutations.size())
	print("additional slots: ", additional_sigil_sprites.size())

	update_base_sigils()
	update_additional_sigils()


func update_base_sigils() -> void:
	for sprite in base_sigil_sprites:
		if is_instance_valid(sprite):
			sprite.visible = false

	var max_count: int = min(card.base_mutations.size(), base_sigil_sprites.size())

	for i in range(max_count):
		var mutation := card.base_mutations[i]
		var sprite := base_sigil_sprites[i]

		if mutation == null:
			print("base sigil blocked: mutation null at ", i)
			continue

		if not is_instance_valid(sprite):
			print("base sigil blocked: sprite invalid at ", i)
			continue

		print("base sigil ", i, " mutation=", mutation.get_tooltip_name(), " texture=", mutation.sigil_texture)

		if mutation.sigil_texture == null:
			print("base sigil blocked: texture null at ", i)
			continue

		sprite.texture = mutation.sigil_texture
		sprite.visible = true
		sprite.z_index = 100

		print("base sigil applied texture: ", sprite.texture)


func update_additional_sigils() -> void:
	for sprite in additional_sigil_sprites:
		if is_instance_valid(sprite):
			sprite.visible = false

	var max_count: int = min(card.additional_mutations.size(), additional_sigil_sprites.size())

	for i in range(max_count):
		var mutation := card.additional_mutations[i]
		var sprite := additional_sigil_sprites[i]

		if mutation == null:
			print("additional sigil blocked: mutation null at ", i)
			continue

		if not is_instance_valid(sprite):
			print("additional sigil blocked: sprite invalid at ", i)
			continue

		print("additional sigil ", i, " mutation=", mutation.get_tooltip_name(), " texture=", mutation.sigil_texture)

		if mutation.sigil_texture == null:
			print("additional sigil blocked: texture null at ", i)
			continue

		sprite.texture = mutation.sigil_texture
		sprite.visible = true
		sprite.z_index = 100

		print("additional sigil applied texture: ", sprite.texture)
