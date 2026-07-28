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
		"owner_ref": weakref(owner),
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

		var owner_ref: WeakRef = entry.get("owner_ref", null) as WeakRef
		var delay: float = float(entry.get("delay", 0.0))
		var callback: Callable = entry.get("callback", Callable()) as Callable

		if owner_ref == null:
			continue

		var owner: Node = owner_ref.get_ref() as Node

		if owner == null:
			continue

		if delay > 0.0:
			var tree := owner.get_tree()

			if tree == null:
				continue

			await tree.create_timer(delay).timeout

		# The owner or callback target may have been freed during the delay.
		owner = owner_ref.get_ref() as Node

		if owner == null:
			continue

		if callback.is_valid():
			callback.call()

	is_playing = false
