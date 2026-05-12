extends Node
class_name WorkerUnionBuffHandler

@export var state_handler: DominantStateHandler
@export var attack_bonus: int = 1
@export var health_bonus: int = 1

func try_apply_to_card(card: Card) -> void:
	if card == null:
		return

	if state_handler == null:
		print("WorkerUnion blocked: state_handler is null")
		return

	if state_handler.current_state != DominantStateHandler.DominantState.ACTIVE:
		print("WorkerUnion inactive/disabled: no buff")
		return

	if card.card_stats == null:
		print("WorkerUnion blocked: card_stats missing on ", card.card_name)
		return

	card.card_stats.apply_stat_bonus(attack_bonus, health_bonus)

	print("WorkerUnion applied to ", card.card_name, " atk=", card.current_attack, " hp=", card.current_health)
