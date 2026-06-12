extends Node
class_name SlotFeedback

@export var play_phase_feedback: SlotPlayPhaseFeedback
@export var placement_preview_feedback: SlotPlacementPreviewFeedback
@export var attack_preview_feedback: SlotAttackPreviewFeedback
@export var damaged_feedback: SlotDamagedFeedback

var slot: Slot = null


func setup(source_slot: Slot) -> void:
	slot = source_slot

	if play_phase_feedback != null:
		play_phase_feedback.setup(self)

	if placement_preview_feedback != null:
		placement_preview_feedback.setup(self)

	if attack_preview_feedback != null:
		attack_preview_feedback.setup(self)

	if damaged_feedback != null:
		damaged_feedback.setup(self)

	show_idle()


func show_playable() -> void:
	if play_phase_feedback != null:
		play_phase_feedback.show_playable()


func show_inactive() -> void:
	if play_phase_feedback != null:
		play_phase_feedback.show_inactive()


func show_idle() -> void:
	if play_phase_feedback != null:
		play_phase_feedback.show_idle()


func show_placement_preview(value: bool) -> void:
	if placement_preview_feedback != null:
		placement_preview_feedback.set_previewed(value)


func show_attack_preview(value: bool) -> void:
	if attack_preview_feedback != null:
		attack_preview_feedback.set_previewed(value)


func show_damaged() -> void:
	if damaged_feedback != null:
		damaged_feedback.play_feedback()


func clear_preview_feedback() -> void:
	show_placement_preview(false)
	show_attack_preview(false)


func clear_all_feedback() -> void:
	clear_preview_feedback()
	show_idle()
