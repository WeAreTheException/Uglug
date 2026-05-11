extends Label

@export var max_font_size: int = 32
@export var min_font_size: int = 10

func _ready() -> void:
	call_deferred("fit_text")

func fit_text() -> void:
	var font_size := max_font_size

	while font_size >= min_font_size:
		add_theme_font_size_override("font_size", font_size)

		await get_tree().process_frame

		var text_width := get_theme_font("font").get_string_size(
			text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size
		).x

		if text_width <= size.x:
			return

		font_size -= 1

	add_theme_font_size_override("font_size", min_font_size)
