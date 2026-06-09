extends Resource
class_name DeathContext

var dead_card: CardRoot = null
var killer_card: CardRoot = null

var dead_slot: Slot = null
var killer_slot: Slot = null

var source_type: String = MutationSource.BASE
var source: Object = null

var should_free_card: bool = true
var should_trigger_death_mutations: bool = true
var should_remove_from_board: bool = true


func setup(
	new_dead_card: CardRoot,
	new_killer_card: CardRoot = null,
	new_source_type: String = MutationSource.BASE,
	new_source: Object = null
) -> void:
	dead_card = new_dead_card
	killer_card = new_killer_card
	source_type = new_source_type
	source = new_source

	if dead_card != null:
		dead_slot = dead_card.get_current_slot()

	if killer_card != null:
		killer_slot = killer_card.get_current_slot()


func is_from_mutation() -> bool:
	return source_type == MutationSource.MUTATION
