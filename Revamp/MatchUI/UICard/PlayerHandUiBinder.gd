extends Node
class_name PlayHandUiBinder

@export var match_ui: MatchUiRoot
@export var player_hand: PlayerHandRoot

@export var active_color: Color = Color.WHITE
@export var completed_color: Color = Color(1.0, 1.0, 1.0, 0.35)
@export var future_color: Color = Color(1.0, 1.0, 1.0, 0.55)

@export var number_color: Color = Color(1.0, 0.9, 0.15, 1.0)

@export var active_font_size: int = 18
@export var normal_font_size: int = 16

@export var select_card_text: String = "Select Card"
@export var choose_martyrs_text: String = "Choose %s martyr%s"
@export var place_text: String = "Place"


func _ready() -> void:
	_connect_hand()
	refresh()


func refresh() -> void:
	if match_ui == null:
		return

	if match_ui.helper_label == null:
		return

	var primed_card: CardRoot = _get_primed_card()

	if primed_card == null:
		_set_helper_text(
			_active_line(select_card_text) + "\n" +
			_future_line("Choose x martyrs") + "\n" +
			_future_line(place_text)
		)
		return

	var required_worth: int = primed_card.get_sacrifice_cost()
	var selected_worth: int = _get_selected_martyr_worth()
	var remaining: int = maxi(required_worth - selected_worth, 0)
	var martyr_plural: String = "" if remaining == 1 else "s"

	var selected_line: String = "Selected %s" % primed_card.card_name
	var martyr_line: String = _martyr_line(remaining, martyr_plural, remaining > 0)

	if remaining > 0:
		_set_helper_text(
			_completed_line(selected_line) + "\n" +
			martyr_line + "\n" +
			_future_line(place_text)
		)
		return

	_set_helper_text(
		_completed_line(selected_line) + "\n" +
		martyr_line + "\n" +
		_active_line(place_text)
	)


func _connect_hand() -> void:
	if player_hand == null:
		return

	if not player_hand.card_primed.is_connected(_on_card_primed):
		player_hand.card_primed.connect(_on_card_primed)

	if not player_hand.card_unprimed.is_connected(_on_card_unprimed):
		player_hand.card_unprimed.connect(_on_card_unprimed)

	if not player_hand.sacrifice_selection_changed.is_connected(_on_sacrifice_selection_changed):
		player_hand.sacrifice_selection_changed.connect(_on_sacrifice_selection_changed)


func _on_card_primed(_card: CardRoot) -> void:
	refresh()


func _on_card_unprimed(_card: CardRoot) -> void:
	refresh()


func _on_sacrifice_selection_changed(_cards: Array[CardRoot]) -> void:
	refresh()


func _get_primed_card() -> CardRoot:
	if player_hand == null:
		return null

	return player_hand.get_primed_card()


func _get_selected_martyr_worth() -> int:
	if player_hand == null:
		return 0

	var total: int = 0

	for card: CardRoot in player_hand.get_selected_sacrifice_cards():
		if card == null:
			continue

		total += card.get_sacrifice_worth()

	return total


func _set_helper_text(text: String) -> void:
	match_ui.helper_label.bbcode_enabled = true
	match_ui.helper_label.text = text


func _martyr_line(remaining: int, martyr_plural: String, is_active: bool) -> String:
	var line_color: Color = active_color if is_active else completed_color
	var font_size: int = active_font_size if is_active else normal_font_size
	var faded_number_color: Color = number_color
	faded_number_color.a = line_color.a

	return "[font_size=%s][color=%s]Choose [/color][color=%s]%s[/color][color=%s] martyr%s[/color][/font_size]" % [
		font_size,
		line_color.to_html(),
		faded_number_color.to_html(),
		remaining,
		line_color.to_html(),
		martyr_plural
	]


func _active_line(text: String) -> String:
	return "[font_size=%s][color=%s]%s[/color][/font_size]" % [
		active_font_size,
		active_color.to_html(),
		text
	]


func _completed_line(text: String) -> String:
	return "[font_size=%s][color=%s]%s[/color][/font_size]" % [
		normal_font_size,
		completed_color.to_html(),
		text
	]


func _future_line(text: String) -> String:
	return "[font_size=%s][color=%s]%s[/color][/font_size]" % [
		normal_font_size,
		future_color.to_html(),
		text
	]
