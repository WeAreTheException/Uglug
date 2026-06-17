extends Node2D
class_name BlessingAnimationHandler

signal intro_finished
signal outro_finished

@export var video_player: VideoStreamPlayer

@export var play_intro_on_ready: bool = false

@export var idle_loop_start_time: float = 2.0
@export var idle_loop_end_time: float = 4.5
@export var outro_start_time: float = 5.0

@export var hide_when_finished: bool = true
@export var print_debug: bool = true

var is_playing_intro: bool = false
var is_looping_idle: bool = false
var is_playing_outro: bool = false


func _ready() -> void:
	visible = false
	modulate.a = 1.0

	if video_player != null:
		video_player.visible = false
		video_player.modulate.a = 1.0

		if not video_player.finished.is_connected(_on_video_finished):
			video_player.finished.connect(_on_video_finished)

	if play_intro_on_ready:
		play_intro()


func _process(_delta: float) -> void:
	if video_player == null:
		return

	if is_playing_intro:
		if video_player.stream_position >= idle_loop_start_time:
			is_playing_intro = false
			is_looping_idle = true

			if print_debug:
				print("BLESSING ANIM INTRO FINISHED")

			intro_finished.emit()

	if is_looping_idle:
		if video_player.stream_position >= idle_loop_end_time:
			video_player.stream_position = idle_loop_start_time
			video_player.play()


func play_intro() -> void:
	stop_all()

	visible = true
	modulate.a = 1.0

	if video_player == null:
		if print_debug:
			print("BLESSING ANIM INTRO BLOCKED: video_player missing")
		_on_intro_finished_fallback()
		return

	video_player.visible = true
	video_player.modulate.a = 1.0
	video_player.stream_position = 0.0
	video_player.play()

	is_playing_intro = true
	is_looping_idle = false
	is_playing_outro = false

	if print_debug:
		print("BLESSING ANIM INTRO PLAYED")


func play_outro() -> void:
	if video_player == null:
		if print_debug:
			print("BLESSING ANIM OUTRO BLOCKED: video_player missing")
		_on_outro_finished()
		return

	visible = true
	modulate.a = 1.0

	is_playing_intro = false
	is_looping_idle = false
	is_playing_outro = true

	video_player.visible = true
	video_player.modulate.a = 1.0
	video_player.paused = false
	video_player.stream_position = outro_start_time
	video_player.play()

	if print_debug:
		print("BLESSING ANIM OUTRO PLAYED")


func stop_all() -> void:
	if video_player != null:
		video_player.stop()
		video_player.visible = false
		video_player.modulate.a = 1.0

	is_playing_intro = false
	is_looping_idle = false
	is_playing_outro = false


func _on_intro_finished_fallback() -> void:
	if print_debug:
		print("BLESSING ANIM INTRO FINISHED")

	intro_finished.emit()


func _on_video_finished() -> void:
	if is_playing_outro:
		_on_outro_finished()


func _on_outro_finished() -> void:
	if not is_playing_outro:
		return

	is_playing_outro = false
	is_playing_intro = false
	is_looping_idle = false

	if video_player != null:
		video_player.stop()
		video_player.visible = false
		video_player.modulate.a = 1.0

	if hide_when_finished:
		visible = false

	modulate.a = 1.0

	if print_debug:
		print("BLESSING ANIM OUTRO FINISHED")

	outro_finished.emit()
