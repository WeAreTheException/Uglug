extends Button
class_name BuffPile

@export var mutation_scene: PackedScene
@export var spawn_anchor: Node2D

var buff_database: BuffDatabase = null

func _ready() -> void:
	buff_database = get_node_or_null("BuffDatabase") as BuffDatabase

func _pressed() -> void:
	if buff_database == null:
		print("buff pile blocked: buff_database is null")
		return

	if mutation_scene == null:
		print("buff pile blocked: mutation_scene is null")
		return

	if spawn_anchor == null:
		print("buff pile blocked: spawn_anchor is null")
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
