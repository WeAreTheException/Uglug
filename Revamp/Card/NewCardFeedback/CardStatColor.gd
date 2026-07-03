extends Node
class_name CardStatColor

@export_group("Attack Label")
@export var attack_label: RichTextLabel

@export var attack_idle_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var attack_buffed_color: Color = Color(0.65, 1.0, 0.35, 1.0)
@export var attack_debuffed_color: Color = Color(1.0, 0.25, 0.25, 1.0)

@export_group("Health Label")
@export var health_label: RichTextLabel

@export var health_idle_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var health_buffed_color: Color = Color(0.65, 1.0, 0.35, 1.0)
@export var health_debuffed_color: Color = Color(1.0, 0.25, 0.25, 1.0)

@export var print_debug: bool = true


func _ready() -> void:
	call_deferred("apply_idle_colors")


func apply_idle_colors() -> void:
	apply_attack_idle_color()
	apply_health_idle_color()


func apply_attack_idle_color() -> void:
	_apply_rich_text_color(attack_label, attack_idle_color)


func apply_attack_buffed_color() -> void:
	_apply_rich_text_color(attack_label, attack_buffed_color)


func apply_attack_debuffed_color() -> void:
	_apply_rich_text_color(attack_label, attack_debuffed_color)


func apply_health_idle_color() -> void:
	_apply_rich_text_color(health_label, health_idle_color)


func apply_health_buffed_color() -> void:
	_apply_rich_text_color(health_label, health_buffed_color)


func apply_health_debuffed_color() -> void:
	_apply_rich_text_color(health_label, health_debuffed_color)


func reset_all_stat_colors() -> void:
	apply_idle_colors()


func _apply_rich_text_color(label: RichTextLabel, color: Color) -> void:
	if label == null:
		return

	label.modulate = Color.WHITE
	label.self_modulate = Color.WHITE

	label.remove_theme_color_override("default_color")
	label.remove_theme_color_override("font_color")

	label.add_theme_color_override("default_color", color)
	label.add_theme_color_override("font_color", color)

	# RichTextLabel can be annoying with theme overrides, so force redraw.
	label.queue_redraw()


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardStatColor] ", message)
