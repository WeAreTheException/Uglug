extends Button
class_name BuffPile

@export var mutation_scene: PackedScene
@export var spawn_anchor: Node2D

var buff_database: BuffDatabase = null

func _ready() -> void:
	buff_database = get_node_or_null("BuffDatabase") as BuffDatabase

	if spawn_anchor == null:
		spawn_anchor = find_child("BuffInstanceSpawnAncho", true, false) as Node2D

	if spawn_anchor == null:
		spawn_anchor = find_child("BuffInstanceSpawnAnchor", true, false) as Node2D

	print("BuffPile ready on: ", get_path())
	print("mutation_scene = ", mutation_scene)
	print("spawn_anchor = ", spawn_anchor)
	print("buff_database = ", buff_database)

func _pressed() -> void:
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

	var instance := mutation_scene.instantiate()

	get_tree().current_scene.add_child(instance)

	if instance is Node2D:
		instance.global_position = spawn_anchor.global_position

	if instance.has_method("setup_mutation"):
		instance.setup_mutation(mutation)
