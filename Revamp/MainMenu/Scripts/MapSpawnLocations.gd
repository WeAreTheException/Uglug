extends Node
class_name MapSpawnLocations

@export var spawn_points: Array[Marker2D]
@export var minimum_spawn_distance := 64.0


func get_spawn_position(spawn_id: int) -> Vector2:
	if spawn_points.is_empty():
		return Vector2.ZERO

	if not is_valid_spawn_id(spawn_id):
		return spawn_points[0].global_position

	return spawn_points[spawn_id].global_position


func get_spawn_count() -> int:
	return spawn_points.size()


func get_random_spawn_id() -> int:
	var valid_ids := get_valid_spawn_ids()

	if valid_ids.is_empty():
		return 0

	return valid_ids.pick_random()


func is_valid_spawn_id(spawn_id: int) -> bool:
	if spawn_id < 0 or spawn_id >= spawn_points.size():
		return false

	if spawn_points[spawn_id] == null:
		return false

	return not _is_too_close_to_previous_spawn(spawn_id)


func get_valid_spawn_ids() -> Array[int]:
	var valid_ids: Array[int] = []

	for i in range(spawn_points.size()):
		if is_valid_spawn_id(i):
			valid_ids.append(i)

	return valid_ids


func print_spawn_debug() -> void:
	print("Spawn count: ", get_spawn_count())
	print("Minimum spawn distance: ", minimum_spawn_distance)

	for i in range(spawn_points.size()):
		if spawn_points[i] == null:
			print("Spawn ", i, ": INVALID - marker is null")
			continue

		var position := spawn_points[i].global_position

		if _is_too_close_to_previous_spawn(i):
			var closest_id := _get_closest_previous_spawn_id(i)
			var distance := position.distance_to(spawn_points[closest_id].global_position)

			print(
				"Spawn ",
				i,
				": INVALID - too close to Spawn ",
				closest_id,
				" Distance: ",
				distance,
				" Position: ",
				position
			)
			continue

		print("Spawn ", i, ": VALID Position: ", position)


func _is_too_close_to_previous_spawn(spawn_id: int) -> bool:
	var current_spawn := spawn_points[spawn_id]

	if current_spawn == null:
		return true

	for i in range(spawn_id):
		var other_spawn := spawn_points[i]

		if other_spawn == null:
			continue

		var distance := current_spawn.global_position.distance_to(other_spawn.global_position)

		if distance < minimum_spawn_distance:
			return true

	return false


func _get_closest_previous_spawn_id(spawn_id: int) -> int:
	var closest_id := -1
	var closest_distance := INF
	var current_spawn := spawn_points[spawn_id]

	if current_spawn == null:
		return closest_id

	for i in range(spawn_id):
		var other_spawn := spawn_points[i]

		if other_spawn == null:
			continue

		var distance := current_spawn.global_position.distance_to(other_spawn.global_position)

		if distance < closest_distance:
			closest_distance = distance
			closest_id = i

	return closest_id
