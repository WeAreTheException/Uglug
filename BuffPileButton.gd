extends Button
class_name BuffPileButton

@export var spawned_button_scene: PackedScene
@export var spawn_anchor: Node2D

var spawned_button: Button = null

func _pressed() -> void:
	if spawned_button != null:
		return

	if spawned_button_scene == null:
		print("buff pile blocked: spawned_button_scene is null")
		return

	if spawn_anchor == null:
		print("buff pile blocked: spawn_anchor is null")
		return

	spawned_button = spawned_button_scene.instantiate() as Button

	if spawned_button == null:
		print("buff pile blocked: spawned scene is not a Button")
		return

	get_tree().current_scene.add_child(spawned_button)
	spawned_button.global_position = spawn_anchor.global_position
	spawned_button.pressed.connect(_on_spawned_button_pressed)

func _on_spawned_button_pressed() -> void:
	print("yay")
