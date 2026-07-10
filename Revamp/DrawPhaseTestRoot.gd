extends Node
class_name DrawPhaseTestRoot

signal draw_phase_finished

@export var test_enabled: bool = true

@export var match_ui: MatchUiRoot
@export var player_hand: PlayerHandRoot

@export var worker_card: CardData
@export var warrior_cards: Array[CardData]

@export var active_draw_timer: Timer
@export var auto_draw_timer: Timer
@export var reveal_timer: Timer

@export var restart_test_key: Key = KEY_T
@export var print_debug: bool = true

var drawn_cards: Array[CardRoot] = []
var drawn_types: Array[String] = []
var next_warrior_index: int = 0
var is_draw_finished: bool = false


func _ready() -> void:
	if not test_enabled:
		return

	_connect_ui()
	_connect_timers()
	start_draw_test()


func _process(_delta: float) -> void:
	if not test_enabled:
		return

	if active_draw_timer == null:
		return

	if active_draw_timer.is_stopped():
		return

	if match_ui != null:
		match_ui.set_timer_seconds(active_draw_timer.time_left)


func _unhandled_input(event: InputEvent) -> void:
	if not test_enabled:
		return

	if event is not InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	if event.keycode == restart_test_key:
		start_draw_test()


func start_draw_test() -> void:
	if not test_enabled:
		return

	_stop_timers()

	drawn_cards.clear()
	drawn_types.clear()
	next_warrior_index = 0
	is_draw_finished = false

	if player_hand != null and player_hand.has_method("clear_cards"):
		player_hand.clear_cards()

	if match_ui != null:
		match_ui.clear_draw_log()
		match_ui.set_draw_buttons_enabled(true)
		match_ui.clear_timer()

	if active_draw_timer != null:
		active_draw_timer.start()

	if print_debug:
		print("DRAW TEST STARTED")


func _connect_ui() -> void:
	if match_ui == null:
		return

	if not match_ui.worker_draw_pressed.is_connected(_on_worker_draw_pressed):
		match_ui.worker_draw_pressed.connect(_on_worker_draw_pressed)

	if not match_ui.warrior_draw_pressed.is_connected(_on_warrior_draw_pressed):
		match_ui.warrior_draw_pressed.connect(_on_warrior_draw_pressed)


func _connect_timers() -> void:
	if active_draw_timer != null:
		if not active_draw_timer.timeout.is_connected(_on_active_draw_timeout):
			active_draw_timer.timeout.connect(_on_active_draw_timeout)

	if auto_draw_timer != null:
		if not auto_draw_timer.timeout.is_connected(_on_auto_draw_timeout):
			auto_draw_timer.timeout.connect(_on_auto_draw_timeout)

	if reveal_timer != null:
		if not reveal_timer.timeout.is_connected(_on_reveal_timeout):
			reveal_timer.timeout.connect(_on_reveal_timeout)


func _stop_timers() -> void:
	if active_draw_timer != null:
		active_draw_timer.stop()

	if auto_draw_timer != null:
		auto_draw_timer.stop()

	if reveal_timer != null:
		reveal_timer.stop()


func _on_worker_draw_pressed() -> void:
	if not test_enabled:
		return

	_spawn_worker()


func _on_warrior_draw_pressed() -> void:
	if not test_enabled:
		return

	_spawn_warrior()


func _on_active_draw_timeout() -> void:
	if not test_enabled:
		return

	if match_ui != null:
		match_ui.set_timer_seconds(0.0)
		match_ui.set_draw_buttons_enabled(false)

	if drawn_cards.size() >= 2:
		_finish_or_reveal()
		return

	if auto_draw_timer != null:
		auto_draw_timer.start()


func _on_auto_draw_timeout() -> void:
	if not test_enabled:
		return

	if drawn_cards.size() == 0:
		_auto_spawn_warrior()
		_auto_spawn_worker()
	elif drawn_cards.size() == 1:
		_auto_spawn_worker()

	_finish_or_reveal()


func _finish_or_reveal() -> void:
	if _has_drawn_warrior():
		_start_reveal_timer()
		return

	if match_ui != null:
		match_ui.start_draw_reveal_time()

	_finish_draw_phase()


func _has_drawn_warrior() -> bool:
	for card_type: String in drawn_types:
		if card_type == "warrior":
			return true

	return false


func _on_reveal_timeout() -> void:
	if not test_enabled:
		return

	if match_ui != null:
		match_ui.start_draw_reveal_time()

	for i: int in range(drawn_cards.size()):
		var card: CardRoot = drawn_cards[i]

		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		if drawn_types[i] != "warrior":
			continue

		card.set_hidden_for_draw(false)

		if match_ui != null:
			match_ui.set_draw_log_entry_revealed(i, card.card_name)

	_finish_draw_phase()


func _finish_draw_phase() -> void:
	if is_draw_finished:
		return

	is_draw_finished = true

	if match_ui != null:
		match_ui.set_draw_buttons_enabled(false)
		match_ui.set_timer_seconds(0.0)

	if print_debug:
		print("DRAW TEST FINISHED")

	draw_phase_finished.emit()


func _auto_spawn_worker() -> void:
	if match_ui != null:
		match_ui.add_draw_log_entry("worker")

	_spawn_worker()


func _auto_spawn_warrior() -> void:
	if match_ui != null:
		match_ui.add_draw_log_entry("warrior")

	_spawn_warrior()


func _spawn_worker() -> void:
	if drawn_cards.size() >= 2:
		return

	if player_hand == null:
		return

	if worker_card == null:
		return

	var card: CardRoot = player_hand.spawn_card(worker_card)

	if card == null:
		return

	drawn_cards.append(card)
	drawn_types.append("worker")


func _spawn_warrior() -> void:
	if drawn_cards.size() >= 2:
		return

	if player_hand == null:
		return

	var data: CardData = _get_next_warrior_card()

	if data == null:
		return

	var card: CardRoot = player_hand.spawn_card(data)

	if card == null:
		return

	card.set_hidden_for_draw(true)

	drawn_cards.append(card)
	drawn_types.append("warrior")


func _get_next_warrior_card() -> CardData:
	if warrior_cards.is_empty():
		return null

	var index: int = next_warrior_index % warrior_cards.size()
	next_warrior_index += 1

	return warrior_cards[index]


func _start_reveal_timer() -> void:
	if reveal_timer != null:
		reveal_timer.start()
