extends Node
class_name PlacementCleanup

var controller: PlacementController = null


func setup(source_controller: PlacementController) -> void:
	controller = source_controller


func clear_preview_feedback() -> void:
	if controller == null:
		return

	if controller.placement_preview != null:
		controller.placement_preview.clear_preview()
		controller.placement_preview.clear_cache()

	if controller.attack_preview_resolver != null:
		controller.attack_preview_resolver.clear_preview()
