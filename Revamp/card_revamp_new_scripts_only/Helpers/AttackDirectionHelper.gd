extends RefCounted
class_name AttackDirectionHelper

static func get_direction(difference: int) -> Vector2:
	match difference:
		-3:
			return Vector2(-1, -0.35).normalized()
		-2:
			return Vector2(-1, -0.55).normalized()
		-1:
			return Vector2(-1, -0.85).normalized()
		0:
			return Vector2.UP
		1:
			return Vector2(1, -0.85).normalized()
		2:
			return Vector2(1, -0.55).normalized()
		3:
			return Vector2(1, -0.35).normalized()
	return Vector2.UP

static func get_rotation_side(difference: int) -> float:
	var side: float = signf(float(difference))
	if side == 0.0:
		side = 1.0
	return side
