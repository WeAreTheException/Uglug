extends Node
class_name StatsVisuals

@export var attack_label: Label
@export var health_label: Label
@export var cost_label: Label
@export var worth_label: Label
@export var name_label: Label

var stats: CardStats = null

func setup_from_stats(source_stats: CardStats, card_name: String) -> void:
	_disconnect_stats()
	stats = source_stats
	if name_label != null:
		name_label.text = card_name
	if stats == null:
		return
	_connect_stats()
	_refresh_all()

func _connect_stats() -> void:
	if not stats.attack_changed.is_connected(_on_attack_changed):
		stats.attack_changed.connect(_on_attack_changed)
	if not stats.health_changed.is_connected(_on_health_changed):
		stats.health_changed.connect(_on_health_changed)
	if not stats.cost_changed.is_connected(_on_cost_changed):
		stats.cost_changed.connect(_on_cost_changed)
	if not stats.worth_changed.is_connected(_on_worth_changed):
		stats.worth_changed.connect(_on_worth_changed)

func _disconnect_stats() -> void:
	if stats == null:
		return
	if stats.attack_changed.is_connected(_on_attack_changed):
		stats.attack_changed.disconnect(_on_attack_changed)
	if stats.health_changed.is_connected(_on_health_changed):
		stats.health_changed.disconnect(_on_health_changed)
	if stats.cost_changed.is_connected(_on_cost_changed):
		stats.cost_changed.disconnect(_on_cost_changed)
	if stats.worth_changed.is_connected(_on_worth_changed):
		stats.worth_changed.disconnect(_on_worth_changed)

func _refresh_all() -> void:
	_on_attack_changed(stats.get_attack())
	_on_health_changed(stats.get_health())
	_on_cost_changed(stats.get_cost())
	_on_worth_changed(stats.get_worth())

func _on_attack_changed(value: int) -> void:
	if attack_label != null:
		attack_label.text = str(value)

func _on_health_changed(value: int) -> void:
	if health_label != null:
		health_label.text = str(value)

func _on_cost_changed(value: int) -> void:
	if cost_label != null:
		cost_label.text = str(value)

func _on_worth_changed(value: int) -> void:
	if worth_label != null:
		worth_label.text = str(value)
