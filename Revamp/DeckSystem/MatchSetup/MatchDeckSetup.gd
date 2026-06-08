extends Node
class_name MatchDeckSetup

@export var mode_config: MatchDeckModeConfig
@export var seed_config: MatchSeedConfig
@export var classic_class: ClassDefinition
@export var player_one_loadout: PlayerDeckLoadout
@export var player_two_loadout: PlayerDeckLoadout

var root: DeckSystemRoot = null
var classic_builder := ClassicSplitBuilderHelper.new()
var loadout_builder := PlayerLoadoutBuilderHelper.new()
var debug_printer := DeckDebugPrintHelper.new()


func setup(source_root: DeckSystemRoot) -> void:
	root = source_root


func build_match_decks() -> Dictionary:
	var result := {}
	if _is_classic_split():
		result = classic_builder.build(classic_class, _get_seed(), _get_worker_card())
	else:
		result = loadout_builder.build(
			player_one_loadout,
			player_two_loadout,
			_get_seed(),
			_get_worker_card()
		)

	if _should_print_debug():
		debug_printer.print_match_result(result, _get_seed())
	return result


func _is_classic_split() -> bool:
	return mode_config == null or mode_config.is_classic_split()


func _should_print_debug() -> bool:
	return mode_config != null and mode_config.print_debug_results


func _get_seed() -> int:
	return 12345 if seed_config == null else seed_config.get_seed()


func _get_worker_card() -> CardData:
	if root == null or root.worker_source == null:
		return null
	return root.worker_source.get_worker_card()
