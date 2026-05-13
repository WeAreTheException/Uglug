extends Node
class_name WorkerUnionBuffHandler

@export var attack_bonus: int = 1
@export var health_bonus: int = 1

var worker_union_active: bool = false

func set_worker_union_active(value: bool) -> void:
	worker_union_active = value

	print("WorkerUnion active = ", worker_union_active)

func try_apply_to_card(card: Card) -> void:
	if card == null:
		return

	if not worker_union_active:
		print("WorkerUnion inactive: no buff")
		return

	if card.card_stats == null:
		print("WorkerUnion blocked: card_stats missing")
		return

	card.card_stats.apply_stat_bonus(
		attack_bonus,
		health_bonus
	)

	print(
		"WorkerUnion applied to ",
		card.card_name,
		" atk=",
		card.current_attack,
		" hp=",
		card.current_health
	)
