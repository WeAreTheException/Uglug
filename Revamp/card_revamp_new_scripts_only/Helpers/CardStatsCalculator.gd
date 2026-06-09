extends RefCounted
class_name CardStatsCalculator

static func get_modifier_total(
	modifiers: Array[StatModifier],
	stat_name: String
) -> int:
	var total := 0
	for modifier in modifiers:
		if modifier == null:
			continue
		if not modifier.is_active:
			continue
		if modifier.stat_name != stat_name:
			continue
		total += modifier.amount
	return total
