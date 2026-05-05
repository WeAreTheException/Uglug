extends Label
class_name AttackingLabel

@export var turn_manager: TurnManager
@export var visibility_timer: Timer

func _ready() -> void:
	visible = false

	if visibility_timer != null:
		visibility_timer.one_shot = true
		if not visibility_timer.timeout.is_connected(_on_visibility_timer_timeout):
			visibility_timer.timeout.connect(_on_visibility_timer_timeout)

	if turn_manager != null:
		if not turn_manager.turn_player_changed.is_connected(_on_turn_player_changed):
			turn_manager.turn_player_changed.connect(_on_turn_player_changed)

func _on_turn_player_changed(client_id: int, phase_name: String) -> void:
	if phase_name != "Attack":
		return

	var player_name := GDSync.player_get_username(client_id, "Unknown Player")

	text = player_name + " is attacking"
	visible = true

	if visibility_timer != null:
		visibility_timer.start()

func _on_visibility_timer_timeout() -> void:
	visible = false
