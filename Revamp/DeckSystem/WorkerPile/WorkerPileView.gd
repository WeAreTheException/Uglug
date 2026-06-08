extends Node
class_name WorkerPileView

@export var feedback_label: Label


func show_worker_requested() -> void:
	if feedback_label != null:
		feedback_label.text = "Worker"
