extends Label
class_name AttackingFirstLabel

@export var turn_manager: TurnManager
@export var visibility_timer: Timer

func _ready() -> void:
	visible = false

	if visibility_timer != null:
		visibility_timer.one_shot = true
		if not visibility_timer.timeout.is_connected(_on_visibility_timer_timeout):
			visibility_timer.timeout.connect(_on_visibility_timer_timeout)

	if turn_manager != null:
		if not turn_manager.attacking_first_changed.is_connected(_on_attacking_first_changed):
			turn_manager.attacking_first_changed.connect(_on_attacking_first_changed)

func _on_attacking_first_changed(client_id: int) -> void:
	var player_name := GDSync.player_get_username(client_id, "Unknown Player")

	text = player_name + " is attacking first"
	visible = true

	if visibility_timer != null:
		visibility_timer.start()

func _on_visibility_timer_timeout() -> void:
	visible = false
