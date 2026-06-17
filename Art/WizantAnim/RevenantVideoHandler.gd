extends Node2D
class_name RevenantVideoHandler

signal intro_finished
signal outro_finished

@export var intro_player: VideoStreamPlayer
@export var outro_player: VideoStreamPlayer

@export var play_intro_on_ready: bool = false
@export var debug_auto_outro_after_intro: bool = false
@export var debug_auto_outro_delay: float = 0.25

@export var use_debug_outro_fade: bool = true
@export var debug_outro_fade_time: float = 0.35

@export var hide_when_finished: bool = true
@export var print_debug: bool = true

var is_playing_intro: bool = false
var is_playing_outro: bool = false
var last_visible_player: VideoStreamPlayer = null


func _ready() -> void:
	visible = false
	modulate.a = 1.0

	_setup_player(intro_player)
	_setup_player(outro_player)

	if intro_player != null:
		if not intro_player.finished.is_connected(_on_intro_finished):
			intro_player.finished.connect(_on_intro_finished)

	if outro_player != null:
		if not outro_player.finished.is_connected(_on_outro_finished):
			outro_player.finished.connect(_on_outro_finished)

	if play_intro_on_ready:
		play_intro()


func play_intro() -> void:
	stop_all()

	visible = true
	modulate.a = 1.0
	is_playing_intro = true
	is_playing_outro = false

	if intro_player == null:
		if print_debug:
			print("REVENANT INTRO BLOCKED: intro_player missing")
		_on_intro_finished()
		return

	intro_player.modulate.a = 1.0
	intro_player.visible = true
	intro_player.play()
	last_visible_player = intro_player

	if print_debug:
		print("REVENANT INTRO PLAYED")


func play_outro() -> void:
	is_playing_intro = false
	is_playing_outro = true
	visible = true
	modulate.a = 1.0

	if use_debug_outro_fade:
		_play_debug_outro_fade()
		return

	stop_all()

	if outro_player == null:
		if print_debug:
			print("REVENANT OUTRO BLOCKED: outro_player missing")
		_on_outro_finished()
		return

	outro_player.modulate.a = 1.0
	outro_player.visible = true
	outro_player.play()
	last_visible_player = outro_player

	if print_debug:
		print("REVENANT OUTRO PLAYED")


func stop_all() -> void:
	if intro_player != null:
		intro_player.stop()
		intro_player.visible = false
		intro_player.modulate.a = 1.0

	if outro_player != null:
		outro_player.stop()
		outro_player.visible = false
		outro_player.modulate.a = 1.0

	is_playing_intro = false
	is_playing_outro = false


func _setup_player(player: VideoStreamPlayer) -> void:
	if player == null:
		return

	player.visible = false
	player.modulate.a = 1.0


func _play_debug_outro_fade() -> void:
	var target := _get_debug_fade_target()

	if target == null:
		if print_debug:
			print("REVENANT DEBUG OUTRO FADE BLOCKED: no target")
		_on_outro_finished()
		return

	if print_debug:
		print("REVENANT DEBUG OUTRO FADE PLAYED")

	target.visible = true
	target.modulate.a = 1.0

	var tween := create_tween()
	tween.tween_property(target, "modulate:a", 0.0, debug_outro_fade_time)
	await tween.finished

	_on_outro_finished()


func _get_debug_fade_target() -> VideoStreamPlayer:
	if last_visible_player != null and is_instance_valid(last_visible_player):
		return last_visible_player

	if intro_player != null:
		return intro_player

	if outro_player != null:
		return outro_player

	return null


func _on_intro_finished() -> void:
	if not is_playing_intro:
		return

	is_playing_intro = false

	if print_debug:
		print("REVENANT INTRO FINISHED")

	intro_finished.emit()

	if debug_auto_outro_after_intro:
		await get_tree().create_timer(debug_auto_outro_delay).timeout
		play_outro()


func _on_outro_finished() -> void:
	if not is_playing_outro:
		return

	is_playing_outro = false

	if intro_player != null:
		intro_player.stop()
		intro_player.visible = false
		intro_player.modulate.a = 1.0

	if outro_player != null:
		outro_player.stop()
		outro_player.visible = false
		outro_player.modulate.a = 1.0

	if hide_when_finished:
		visible = false

	modulate.a = 1.0
	last_visible_player = null

	if print_debug:
		print("REVENANT OUTRO FINISHED")

	outro_finished.emit()
