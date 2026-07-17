extends RefCounted
class_name StatFeedbackEvent

var source_card: CardRoot = null
var target_card: CardRoot = null

var source_feedback_type: String = ""
var target_feedback_type: String = ""

var modifier: StatModifier = null

var stat_names: Array[String] = []
var stat_amounts: Dictionary = {}


func setup(
	new_source_card: CardRoot,
	new_target_card: CardRoot,
	new_source_feedback_type: String,
	new_target_feedback_type: String,
	new_stat_name: String,
	new_amount: int,
	new_modifier: StatModifier
) -> void:
	source_card = new_source_card
	target_card = new_target_card
	source_feedback_type = new_source_feedback_type
	target_feedback_type = new_target_feedback_type
	modifier = new_modifier

	stat_names.clear()
	stat_amounts.clear()

	add_stat_change(new_stat_name, new_amount)


func add_stat_change(stat_name: String, amount: int) -> void:
	if stat_name == "":
		return

	if amount <= 0:
		return

	if not stat_names.has(stat_name):
		stat_names.append(stat_name)

	var current_amount: int = int(stat_amounts.get(stat_name, 0))
	stat_amounts[stat_name] = current_amount + amount


func merge_from(other: StatFeedbackEvent) -> void:
	if other == null:
		return

	for stat_name: String in other.stat_names:
		var amount: int = int(other.stat_amounts.get(stat_name, 0))
		add_stat_change(stat_name, amount)


func can_merge_with(other: StatFeedbackEvent) -> bool:
	if other == null:
		return false

	if source_card != other.source_card:
		return false

	if target_card != other.target_card:
		return false

	if source_feedback_type != other.source_feedback_type:
		return false

	if target_feedback_type != other.target_feedback_type:
		return false

	return true


func is_valid_event() -> bool:
	if target_card == null:
		return false

	if not is_instance_valid(target_card):
		return false

	if stat_names.is_empty():
		return false

	if source_feedback_type == "":
		return false

	if target_feedback_type == "":
		return false

	return true


func get_source_key() -> String:
	return "_pending_" + source_feedback_type + "_feedback"


func play_source_feedback() -> void:
	if source_card == null:
		return

	if not is_instance_valid(source_card):
		return

	match source_feedback_type:
		"buffer":
			source_card.play_buffer_feedback()

		"debuffer":
			source_card.play_debuffer_feedback()


func play_target_feedback() -> void:
	if target_card == null:
		return

	if not is_instance_valid(target_card):
		return

	match target_feedback_type:
		"buffed":
			target_card.play_buffed_feedback()

		"debuffed":
			target_card.play_debuffed_feedback()


func get_debug_source_name() -> String:
	if source_card == null:
		return "unknown"

	if not is_instance_valid(source_card):
		return "invalid"

	return source_card.card_name


func get_debug_target_name() -> String:
	if target_card == null:
		return "unknown"

	if not is_instance_valid(target_card):
		return "invalid"

	return target_card.card_name


func get_debug_stats_text() -> String:
	var parts: Array[String] = []

	for stat_name: String in stat_names:
		var amount: int = int(stat_amounts.get(stat_name, 0))
		parts.append(stat_name + ":" + str(amount))

	return ", ".join(parts)
