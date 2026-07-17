extends RefCounted
class_name StatFeedbackQueueHelper

static var feedback_queue: Array[Dictionary] = []
static var is_playing: bool = false


static func enqueue(owner: Node, delay: float, callback: Callable) -> void:
	if owner == null:
		return

	if callback.is_null():
		return

	feedback_queue.append({
		"owner": owner,
		"delay": delay,
		"callback": callback
	})

	if is_playing:
		return

	_play_queue()


static func _play_queue() -> void:
	is_playing = true

	while feedback_queue.size() > 0:
		var entry: Dictionary = feedback_queue.pop_front()

		var owner: Node = entry.get("owner", null) as Node
		var delay: float = float(entry.get("delay", 0.0))
		var callback: Callable = entry.get("callback", Callable()) as Callable

		if owner == null:
			continue

		if not is_instance_valid(owner):
			continue

		if delay > 0.0:
			await owner.get_tree().create_timer(delay).timeout

		if callback.is_valid():
			callback.call()

	is_playing = false
