extends Node
class_name Sacrifice

var card: CardRoot = null
var is_anticipating := false
var is_marked := false
var is_pending := false

func setup(source_card: CardRoot) -> void:
	card = source_card

func start_anticipation() -> void:
	is_anticipating = true
	_play_sacrifice_feedback()

func stop_anticipation() -> void:
	is_anticipating = false
	_play_sacrifice_feedback()

func set_marked_for_sacrifice(value: bool) -> void:
	is_marked = value
	_play_sacrifice_feedback()

func set_pending_sacrifice(value: bool) -> void:
	is_pending = value
	_play_sacrifice_feedback()

func play_committed_sacrifice() -> void:
	if card != null and card.feedback_root != null:
		card.feedback_root.play_sacrifice_committed()

func reset_sacrifice_state() -> void:
	is_anticipating = false
	is_marked = false
	is_pending = false
	_play_sacrifice_feedback()

func _play_sacrifice_feedback() -> void:
	if card == null or card.feedback_root == null:
		return
	if is_pending or is_marked:
		card.feedback_root.play_sacrifice_selected()
	elif is_anticipating:
		card.feedback_root.play_sacrifice_idle()
	else:
		card.feedback_root.stop_sacrifice_feedback()
