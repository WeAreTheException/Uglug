extends Resource
class_name DamageContext

var source_card: CardRoot = null
var target_card: CardRoot = null

var source_slot: Slot = null
var target_slot: Slot = null

var base_damage: int = 0
var bonus_damage: int = 0
var final_damage: int = 0
var actual_damage: int = 0

var source_type: String = MutationSource.BASE
var source: Object = null

var can_trigger_damaged: bool = true
var can_trigger_damage_dealt: bool = true


func setup(
	new_source_card: CardRoot,
	new_target_card: CardRoot,
	damage: int,
	new_source_type: String = MutationSource.BASE,
	new_source: Object = null
) -> void:
	source_card = new_source_card
	target_card = new_target_card
	base_damage = damage
	final_damage = damage
	source_type = new_source_type
	source = new_source


func add_bonus_damage(amount: int) -> void:
	bonus_damage += amount
	final_damage = max(base_damage + bonus_damage, 0)


func set_final_damage(amount: int) -> void:
	final_damage = max(amount, 0)


func is_from_mutation() -> bool:
	return source_type == MutationSource.MUTATION
