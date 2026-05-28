extends Resource
class_name StatModifier

enum DurationType {
	PERMANENT,
	AURA,
	TEMPORARY_TURNS,
	CONDITIONAL
}

@export var stat_name: String = ""
@export var amount: int = 0
@export var duration_type: DurationType = DurationType.PERMANENT
@export var turns_left: int = -1

var source: Object = null
var is_active: bool = true
