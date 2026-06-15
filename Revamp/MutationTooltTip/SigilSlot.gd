extends Node2D
class_name SigilSlot

signal hovered(slot: SigilSlot)
signal unhovered(slot: SigilSlot)
signal right_clicked(slot: SigilSlot)
signal left_clicked(slot: SigilSlot)

@export var sprite: Sprite2D
@export var input: SigilInput
@export var debug_enabled: bool = true

var runtime: MutationRuntime = null
var mutation: Mutation = null


func _ready() -> void:
	_connect_input()
	clear()


func setup_runtime(source_runtime: MutationRuntime, greyed_out_alpha: float) -> void:
	runtime = source_runtime
	mutation = null

	if runtime != null:
		mutation = runtime.mutation

	if mutation == null:
		clear()
		return

	visible = true

	if sprite != null:
		sprite.texture = mutation.sigil_texture
		sprite.visible = mutation.sigil_texture != null
		sprite.modulate.a = greyed_out_alpha if runtime.is_greyed_out else 1.0

	_set_input_enabled(true)

	if debug_enabled:
		print("SIGIL SLOT SETUP: ", get_mutation_name())


func clear() -> void:
	runtime = null
	mutation = null

	if sprite != null:
		sprite.texture = null
		sprite.visible = false
		sprite.modulate.a = 1.0

	_set_input_enabled(false)
	visible = false


func get_mutation() -> Mutation:
	return mutation


func get_mutation_name() -> String:
	if mutation == null:
		return ""

	return mutation.mutation_name


func get_mutation_description() -> String:
	if mutation == null:
		return ""

	return mutation.mutation_description


func _connect_input() -> void:
	if input == null:
		return

	if not input.sigil_hovered.is_connected(_on_input_hovered):
		input.sigil_hovered.connect(_on_input_hovered)

	if not input.sigil_unhovered.is_connected(_on_input_unhovered):
		input.sigil_unhovered.connect(_on_input_unhovered)

	if not input.sigil_right_clicked.is_connected(_on_input_right_clicked):
		input.sigil_right_clicked.connect(_on_input_right_clicked)

	if not input.sigil_left_clicked.is_connected(_on_input_left_clicked):
		input.sigil_left_clicked.connect(_on_input_left_clicked)


func _set_input_enabled(value: bool) -> void:
	if input == null:
		return

	input.set_input_enabled(value)


func _on_input_hovered(_input: SigilInput) -> void:
	if mutation == null:
		return

	if debug_enabled:
		print("SIGIL SLOT HOVERED: ", get_mutation_name())

	hovered.emit(self)


func _on_input_unhovered(_input: SigilInput) -> void:
	if mutation == null:
		return

	if debug_enabled:
		print("SIGIL SLOT UNHOVERED: ", get_mutation_name())

	unhovered.emit(self)


func _on_input_right_clicked(_input: SigilInput) -> void:
	if mutation == null:
		return

	if debug_enabled:
		print("SIGIL SLOT RIGHT CLICKED: ", get_mutation_name())

	right_clicked.emit(self)


func _on_input_left_clicked(_input: SigilInput) -> void:
	if mutation == null:
		return

	if debug_enabled:
		print("SIGIL SLOT LEFT CLICKED: ", get_mutation_name())

	left_clicked.emit(self)
