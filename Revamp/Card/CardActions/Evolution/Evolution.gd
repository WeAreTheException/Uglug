extends Node
class_name Evolution

signal evolution_started(card: CardRoot)
signal evolution_finished(card: CardRoot)

@export var animation_runner: EvolutionAnimationRunner
@export var print_debug: bool = false

var card: CardRoot = null
var is_playing: bool = false


func setup(
	source_card: CardRoot,
	visual_target: Node2D
) -> void:
	card = source_card

	if animation_runner == null:
		return

	animation_runner.setup(visual_target)

	if not animation_runner.animation_finished.is_connected(
		_on_animation_finished
	):
		animation_runner.animation_finished.connect(
			_on_animation_finished
		)


func play_evolution() -> void:
	if is_playing:
		return

	if card == null:
		return

	is_playing = true
	evolution_started.emit(card)

	if print_debug:
		print("EVOLUTION PLAY | card=", card.card_name)

	if animation_runner == null:
		_finish_evolution()
		return

	animation_runner.play()


func _on_animation_finished() -> void:
	_finish_evolution()


func _finish_evolution() -> void:
	if not is_playing:
		return

	is_playing = false
	evolution_finished.emit(card)
