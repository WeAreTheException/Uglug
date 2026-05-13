extends Button
class_name BuffPile

@export var mutation_scene: PackedScene
@export var spawn_anchor: Node2D
@export var player_hand: NewPlayerHand
@export var phase_manager: PhaseManager

var buff_database: BuffDatabase = null
var current_mutation_instance: MutationInstance = null

func _ready() -> void:
	buff_database = get_node_or_null("BuffDatabase") as BuffDatabase

	if spawn_anchor == null:
		spawn_anchor = find_child("BuffInstanceSpawnAncho", true, false) as Node2D

	if spawn_anchor == null:
		spawn_anchor = find_child("BuffInstanceSpawnAnchor", true, false) as Node2D

	if phase_manager == null:
		phase_manager = get_tree().current_scene.find_child("PhaseManager", true, false) as PhaseManager

	if phase_manager != null:
		phase_manager.phase_changed.connect(_on_phase_changed)

	disabled = true

	print("BuffPile ready on: ", get_path())
	print("mutation_scene = ", mutation_scene)
	print("spawn_anchor = ", spawn_anchor)
	print("buff_database = ", buff_database)
	print("phase_manager = ", phase_manager)
	print("player_hand = ", player_hand)

func _pressed() -> void:
	print("BuffPile pressed ignored: buffs spawn automatically now")

func _on_phase_changed(phase_name: String) -> void:
	if phase_name == "Buff":
		spawn_buff_instance()

func spawn_buff_instance() -> void:
	if current_mutation_instance != null and is_instance_valid(current_mutation_instance):
		print("buff pile blocked: mutation instance already exists")
		return

	if spawn_anchor == null:
		spawn_anchor = find_child("BuffInstanceSpawnAncho", true, false) as Node2D

	if spawn_anchor == null:
		spawn_anchor = find_child("BuffInstanceSpawnAnchor", true, false) as Node2D

	if buff_database == null:
		print("buff pile blocked: buff_database is null on ", get_path())
		return

	if mutation_scene == null:
		print("buff pile blocked: mutation_scene is null on ", get_path())
		return

	if spawn_anchor == null:
		print("buff pile blocked: spawn_anchor is null on ", get_path())
		return

	var mutation := buff_database.get_random_mutation()

	if mutation == null:
		print("buff pile blocked: no mutations")
		return

	var instance := mutation_scene.instantiate() as MutationInstance

	if instance == null:
		print("buff pile blocked: mutation_scene did not instantiate MutationInstance")
		return

	current_mutation_instance = instance

	get_tree().current_scene.add_child(instance)

	instance.global_position = spawn_anchor.global_position
	instance.setup_mutation(mutation, player_hand)

	print("buff pile spawned mutation instance")
