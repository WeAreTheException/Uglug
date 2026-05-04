extends Label
class_name AttackingLabel

@export var turn_manager: TurnManager

var hide_timer: Timer

func _ready() -> void:
	visible = false

	hide_timer = get_node_or_null("Timer") as Timer

	if hide_timer != null:
		hide_timer.one_shot = true
		if not hide_timer.timeout.is_connected(_on_hide_timer_timeout):
			hide_timer.timeout.connect(_on_hide_timer_timeout)
	else:
		print("AttackingLabel: missing child Timer")

	if turn_manager != null:
		if not turn_manager.turn_player_changed.is_connected(_on_turn_player_changed):
			turn_manager.turn_player_changed.connect(_on_turn_player_changed)
	else:
		print("AttackingLabel: turn_manager not assigned")

func _on_turn_player_changed(client_id: int) -> void:
	var player_name := GDSync.player_get_username(client_id, "Unknown Player")

	text = player_name + " is placing"
	visible = true

	print("AttackingLabel: ", text)

	if hide_timer != null:
		hide_timer.start()

func _on_hide_timer_timeout() -> void:
	visible = false
