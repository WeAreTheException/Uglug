extends RefCounted
class_name StatFeedbackQueueHelper

static var feedback_queue: Array[Callable] = []
static var is_playing: bool = false


static func enqueue(owner: Node, delay: float, callback: Callable) -> void:
	if callback.is_null():
		return

	feedback_queue.append(callback)

	if is_playing:
		return

	_play_queue(owner, delay)


static func _play_queue(owner: Node, delay: float) -> void:
	is_playing = true

	while feedback_queue.size() > 0:
		if owner == null:
			break

		if not is_instance_valid(owner):
			break

		if delay > 0.0:
			await owner.get_tree().create_timer(delay).timeout

		var callback: Callable = feedback_queue.pop_front() as Callable

		if callback.is_valid():
			callback.call()

	is_playing = false
