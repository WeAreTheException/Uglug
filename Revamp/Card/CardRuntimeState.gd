extends Node
class_name CardRuntimeState

signal revenant_changed(is_revenant: bool)

var is_revenant: bool = false


func set_revenant(value: bool) -> void:
	if is_revenant == value:
		return

	is_revenant = value
	revenant_changed.emit(is_revenant)


func mark_revenant() -> void:
	set_revenant(true)


func clear_revenant() -> void:
	set_revenant(false)


func has_revenant() -> bool:
	return is_revenant
