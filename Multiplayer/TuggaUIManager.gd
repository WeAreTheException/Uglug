extends Node2D
class_name TuggaUI

@export var tugga_handler: TuggaHandler

@export var player_one_full_texture: Texture2D
@export var player_two_full_texture: Texture2D

@export var player_one_slot_1: Sprite2D
@export var player_one_slot_2: Sprite2D
@export var player_one_slot_3: Sprite2D
@export var player_one_slot_4: Sprite2D
@export var player_one_slot_5: Sprite2D

@export var player_two_slot_1: Sprite2D
@export var player_two_slot_2: Sprite2D
@export var player_two_slot_3: Sprite2D
@export var player_two_slot_4: Sprite2D
@export var player_two_slot_5: Sprite2D

var player_one_empty_textures: Array[Texture2D] = []
var player_two_empty_textures: Array[Texture2D] = []


func _ready() -> void:
	cache_empty_textures()

	if tugga_handler != null and not tugga_handler.scale_changed.is_connected(_on_scale_changed):
		tugga_handler.scale_changed.connect(_on_scale_changed)

	update_ui()


func cache_empty_textures() -> void:
	player_one_empty_textures = [
		player_one_slot_1.texture,
		player_one_slot_2.texture,
		player_one_slot_3.texture,
		player_one_slot_4.texture,
		player_one_slot_5.texture
	]

	player_two_empty_textures = [
		player_two_slot_1.texture,
		player_two_slot_2.texture,
		player_two_slot_3.texture,
		player_two_slot_4.texture,
		player_two_slot_5.texture
	]


func _on_scale_changed(_value: int) -> void:
	update_ui()


func update_ui() -> void:
	if tugga_handler == null:
		return

	var value := tugga_handler.current_value

	update_player_one_slots(value)
	update_player_two_slots(value)


func update_player_one_slots(value: int) -> void:
	var slots := [
		player_one_slot_1,
		player_one_slot_2,
		player_one_slot_3,
		player_one_slot_4,
		player_one_slot_5
	]

	for i in range(slots.size()):
		if value >= i + 1:
			slots[i].texture = player_one_full_texture
		else:
			slots[i].texture = player_one_empty_textures[i]


func update_player_two_slots(value: int) -> void:
	var slots := [
		player_two_slot_1,
		player_two_slot_2,
		player_two_slot_3,
		player_two_slot_4,
		player_two_slot_5
	]

	for i in range(slots.size()):
		if value <= -(i + 1):
			slots[i].texture = player_two_full_texture
		else:
			slots[i].texture = player_two_empty_textures[i]
