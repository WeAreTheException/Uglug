extends Resource
class_name Mutation

@export var mutation_name: String = ""
@export_multiline var mutation_description: String = ""
@export var sigil_texture: Texture2D


func get_attack_priority(_runtime: MutationRuntime) -> int:
	return 0


func add_attack_events(
	_runtime: MutationRuntime,
	_events: Array[String]
) -> void:
	pass


func modify_attack_sequence(
	_runtime: MutationRuntime,
	sequence: Array[String]
) -> Array[String]:
	return sequence


func modify_attack_target(
	_runtime: MutationRuntime,
	_context: AttackContext
) -> void:
	pass

func modify_incoming_damage(
	_runtime: MutationRuntime,
	_card: CardRoot,
	_attacker: CardRoot,
	damage: int
) -> int:
	return damage

func mutation_attack(_card: CardRoot) -> bool:
	return false


func on_death(_card: CardRoot) -> void:
	pass


func on_damaged(
	_card: CardRoot,
	_attacker: CardRoot,
	_damage: int
) -> void:
	pass


func modify_damage(
	_card: CardRoot,
	_target: CardRoot,
	damage: int
) -> int:
	return damage


func get_attack_target(
	_card: CardRoot,
	target: CardRoot
) -> CardRoot:
	return target


func get_attack_targets(
	_card: CardRoot,
	targets: Array[CardRoot]
) -> Array[CardRoot]:
	return targets
