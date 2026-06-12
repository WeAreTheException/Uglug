extends Node2D
class_name LobbyBounceFeedback

@export var bounce_distance := 6.0
@export var bounce_time := 0.4

var base_position := Vector2.ZERO
var bounce_tween: Tween


func _ready() -> void:
	base_position = position


func start_bounce() -> void:
	stop_bounce()

	bounce_tween = create_tween()
	bounce_tween.set_loops()
	bounce_tween.set_trans(Tween.TRANS_SINE)
	bounce_tween.set_ease(Tween.EASE_IN_OUT)

	bounce_tween.tween_property(self, "position:y", base_position.y - bounce_distance, bounce_time)
	bounce_tween.tween_property(self, "position:y", base_position.y, bounce_time)


func stop_bounce() -> void:
	if bounce_tween != null:
		bounce_tween.kill()
		bounce_tween = null

	position = base_position
