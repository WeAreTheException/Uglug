extends Control
class_name MainMenuRoot

@export var map_visual: TextureRect
@export var lobby_icon_layer: Control
@export var host_button: Button
@export var join_random_button: Button
@export var create_lobby_popup: Control
@export var join_private_popup: Control


func _ready() -> void:
	create_lobby_popup.visible = false
	join_private_popup.visible = false


	host_button.pressed.connect(_on_host_pressed)

func _on_host_pressed() -> void:
	create_lobby_popup.visible = true
