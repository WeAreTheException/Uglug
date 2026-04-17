extends CanvasLayer
class_name QuirkTooltip

@export var panel: Panel
@export var label: RichTextLabel
@export var mouse_offset: Vector2 = Vector2(20, 20)

func _ready() -> void:
	hide_tooltip()

func show_tooltip(title_text: String, body_text: String, screen_position: Vector2) -> void:
	var final_text := ""

	if title_text.strip_edges() != "":
		final_text += "[b]" + title_text + "[/b]"

	if body_text.strip_edges() != "":
		if final_text != "":
			final_text += "\n"
		final_text += body_text

	if final_text.strip_edges() == "":
		hide_tooltip()
		return

	label.bbcode_enabled = true
	label.text = final_text

	panel.position = screen_position + mouse_offset
	panel.visible = true

func move_tooltip(screen_position: Vector2) -> void:
	if not panel.visible:
		return

	panel.position = screen_position + mouse_offset

func hide_tooltip() -> void:
	panel.visible = false
