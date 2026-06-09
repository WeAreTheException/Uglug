extends Resource
class_name AttackStep

const FORWARD := "FORWARD"
const LEFT := "LEFT"
const RIGHT := "RIGHT"

@export var direction: String = FORWARD
@export var source_type: String = MutationSource.BASE
@export var source: Object = null

var attacker_card: CardRoot = null
var origin_slot: Slot = null
var target_slot: Slot = null


func setup(
	new_direction: String,
	new_source_type: String = MutationSource.BASE,
	new_source: Object = null
) -> void:
	direction = new_direction
	source_type = new_source_type
	source = new_source


func is_from_mutation() -> bool:
	return source_type == MutationSource.MUTATION


func is_base_attack() -> bool:
	return source_type == MutationSource.BASE
