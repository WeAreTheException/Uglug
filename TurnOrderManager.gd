extends Node
class_name TurnManager

const DEBUG_PLACE_SECONDS := 6.0

@export var phase_manager: PhaseManager

var first_placer_id: int = -1
var second_placer_id: int = -1
var local_place_active: bool = false

func _ready() -> void:
	print("TURN MANAGER READY")
	print("my GD-Sync id: ", GDSync.get_client_id())
	print("host id: ", GDSync.get_host())
	print("am I host: ", GDSync.is_host())

	GDSync.expose_node(self)
	GDSync.expose_func(receive_place_order)
	GDSync.expose_func(first_placer_done)
	GDSync.expose_func(start_second_placer_turn)
	GDSync.expose_func(second_placer_done)

	await get_tree().create_timer(1.0).timeout

	if GDSync.is_host():
		_choose_random_place_order()
	else:
		print("CLIENT WAITING FOR PLACE ORDER")

func _choose_random_place_order() -> void:
	var clients := GDSync.lobby_get_all_clients()

	print("host choosing place order from clients: ", clients)

	if clients.size() < 2:
		print("ERROR: not enough clients to choose place order")
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var first_index := rng.randi_range(0, clients.size() - 1)
	first_placer_id = int(clients[first_index])

	for id in clients:
		if int(id) != first_placer_id:
			second_placer_id = int(id)
			break

	print("RANDOM PLACE ORDER CHOSEN")
	print("first placer id: ", first_placer_id)
	print("second placer id: ", second_placer_id)

	GDSync.call_func_all(receive_place_order, first_placer_id, second_placer_id)

func receive_place_order(first_id: int, second_id: int) -> void:
	first_placer_id = first_id
	second_placer_id = second_id

	var my_id := GDSync.get_client_id()

	print("PLACE ORDER RECEIVED")
	print("my id: ", my_id)
	print("first placer id: ", first_placer_id)
	print("second placer id: ", second_placer_id)

	if my_id == first_placer_id:
		_start_my_place_turn("FIRST")
	else:
		print("I WAIT. OPPONENT PLACES FIRST.")

func _start_my_place_turn(order_label: String) -> void:
	if phase_manager != null and not phase_manager.is_place_phase():
		print("Turn blocked: phase is not PLACE")
		return

	local_place_active = true

	print("================================")
	print("I PLACE ", order_label)
	print("YOU CAN PLACE CARDS NOW")
	print("DEBUG TIMER: ", DEBUG_PLACE_SECONDS, " seconds")
	print("================================")

	await get_tree().create_timer(DEBUG_PLACE_SECONDS).timeout

	if not local_place_active:
		return

	_finish_my_place_turn()

func _finish_my_place_turn() -> void:
	if not local_place_active:
		return

	local_place_active = false

	var my_id := GDSync.get_client_id()

	print("MY PLACE TURN FINISHED")

	if my_id == first_placer_id:
		print("I WAS FIRST PLACER. REPORTING DONE.")
		if GDSync.is_host():
			first_placer_done()
		else:
			GDSync.call_func_on(GDSync.get_host(), first_placer_done)

	elif my_id == second_placer_id:
		print("I WAS SECOND PLACER. REPORTING DONE.")
		if GDSync.is_host():
			second_placer_done()
		else:
			GDSync.call_func_on(GDSync.get_host(), second_placer_done)

func first_placer_done() -> void:
	if not GDSync.is_host():
		return

	print("HOST RECEIVED: FIRST PLACER DONE")
	print("UNLOCKING SECOND PLACER: ", second_placer_id)

	GDSync.call_func_all(start_second_placer_turn, second_placer_id)

func start_second_placer_turn(second_id: int) -> void:
	second_placer_id = second_id

	var my_id := GDSync.get_client_id()

	if my_id == second_placer_id:
		_start_my_place_turn("SECOND")
	else:
		print("I AM DONE. OPPONENT PLACES SECOND.")

func second_placer_done() -> void:
	if not GDSync.is_host():
		return

	if phase_manager != null:
		phase_manager.set_done()

	print("HOST RECEIVED: SECOND PLACER DONE")
	print("================================")
	print("DEBUG PLACEMENT ORDER TEST COMPLETE")
	print("================================")

func is_my_place_turn() -> bool:
	return local_place_active
