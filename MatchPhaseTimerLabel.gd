extends Label
class_name MatchPhaseTimerLabel

@export var phase_timer: MatchPhaseTimer


func _ready() -> void:
	if phase_timer == null:
		return

	if not phase_timer.timer_started.is_connected(
		_on_timer_started
	):
		phase_timer.timer_started.connect(
			_on_timer_started
		)

	if not phase_timer.timer_ticked.is_connected(
		_on_timer_ticked
	):
		phase_timer.timer_ticked.connect(
			_on_timer_ticked
		)

	if not phase_timer.timer_finished.is_connected(
		_on_timer_finished
	):
		phase_timer.timer_finished.connect(
			_on_timer_finished
		)

	_update_text(
		phase_timer.get_remaining_seconds()
	)


func _on_timer_started(
	_state: MatchFlowRoot.MatchState,
	duration: float
) -> void:
	_update_text(duration)


func _on_timer_ticked(
	_state: MatchFlowRoot.MatchState,
	remaining: float
) -> void:
	_update_text(remaining)


func _on_timer_finished(
	_state: MatchFlowRoot.MatchState
) -> void:
	_update_text(0.0)


func _update_text(seconds: float) -> void:
	var rounded_seconds: int = ceili(
		maxf(seconds, 0.0)
	)

	if rounded_seconds >= 60:
		var minutes: int = rounded_seconds / 60
		var leftover_seconds: int = rounded_seconds % 60

		text = "%d:%02d" % [
			minutes,
			leftover_seconds
		]
		return

	text = str(rounded_seconds)
