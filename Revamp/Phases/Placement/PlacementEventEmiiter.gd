extends Node
class_name PlacementEventEmitter

signal card_placed(event: Dictionary)

var controller: PlacementController = null


func setup(source_controller: PlacementController) -> void:
	controller = source_controller


func emit_card_placed(event: Dictionary) -> void:
	if event.is_empty():
		return

	card_placed.emit(event)
