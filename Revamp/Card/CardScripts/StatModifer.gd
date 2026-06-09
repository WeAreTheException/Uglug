extends Resource
class_name StatModifier

@export var stat_name: String = ""
@export var amount: int = 0
@export var duration_type: String = StatModifierDurationTypes.PERMANENT
@export var source_type: String = StatModifierSourceTypes.BASE
@export var turns_left: int = -1

var source: Object = null
var is_active: bool = true
