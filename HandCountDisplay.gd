extends Control
class_name HandCountDisplay

@export var player_hand: PlayerHandRoot
@export var count_label: Label

@export var show_max_count: bool = true
@export var empty_text: String = "Hand: 0"


func _ready() -> void:
	_connect_player_hand()
	_refresh()


func _connect_player_hand() -> void:
	if player_hand == null:
		return

	if not player_hand.hand_changed.is_connected(_on_hand_changed):
		player_hand.hand_changed.connect(_on_hand_changed)

	if not player_hand.card_added.is_connected(_on_card_changed):
		player_hand.card_added.connect(_on_card_changed)

	if not player_hand.card_removed.is_connected(_on_card_changed):
		player_hand.card_removed.connect(_on_card_changed)


func _on_hand_changed() -> void:
	_refresh()


func _on_card_changed(_card: CardRoot) -> void:
	_refresh()


func _refresh() -> void:
	if count_label == null:
		return

	if player_hand == null:
		count_label.text = empty_text
		return

	var current_count := player_hand.get_card_count()

	if show_max_count:
		count_label.text = "%s/%s" % [
			current_count,
			player_hand.max_hand_size
		]
	else:
		count_label.text = "Hand: %s" % current_count
