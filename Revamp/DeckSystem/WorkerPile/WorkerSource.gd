extends Node
class_name WorkerSource

signal worker_requested(card_data: CardData)

@export var worker_card: CardData
@export var view: WorkerPileView


func get_worker_card() -> CardData:
	if worker_card == null:
		return null
	worker_requested.emit(worker_card)
	if view != null:
		view.show_worker_requested()
	return worker_card
