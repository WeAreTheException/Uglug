extends Sprite2D
class_name TuggaManager

@export var battle_scale: BattleScale

@export var texture_neg_5: Texture2D
@export var texture_neg_4: Texture2D
@export var texture_neg_3: Texture2D
@export var texture_neg_2: Texture2D
@export var texture_neg_1: Texture2D
@export var texture_0: Texture2D
@export var texture_1: Texture2D
@export var texture_2: Texture2D
@export var texture_3: Texture2D
@export var texture_4: Texture2D
@export var texture_5: Texture2D

func _ready() -> void:
	if battle_scale != null and not battle_scale.scale_changed.is_connected(_on_scale_changed):
		battle_scale.scale_changed.connect(_on_scale_changed)

	update_sprite()

func _on_scale_changed(_value: int) -> void:
	update_sprite()

func update_sprite() -> void:
	if battle_scale == null:
		return

	match battle_scale.current_value:
		-5:
			texture = texture_neg_5
		-4:
			texture = texture_neg_4
		-3:
			texture = texture_neg_3
		-2:
			texture = texture_neg_2
		-1:
			texture = texture_neg_1
		0:
			texture = texture_0
		1:
			texture = texture_1
		2:
			texture = texture_2
		3:
			texture = texture_3
		4:
			texture = texture_4
		5:
			texture = texture_5
