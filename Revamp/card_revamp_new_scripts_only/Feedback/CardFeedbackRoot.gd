extends Node
class_name CardFeedbackRoot

@export var scale_feedback: ScaleFeedback
@export var position_feedback: PositionFeedback
@export var shadow_feedback: ShadowFeedback
@export var shake_feedback: ShakeFeedback
@export var flash_feedback: FlashFeedback
@export var audio_feedback: AudioFeedback
@export var hover_feedback: CardHoverFeedback
@export var select_feedback: CardSelectFeedback
@export var attack_feedback: AttackFeedback
@export var hurt_feedback: HurtFeedback
@export var death_feedback: DeathFeedback
@export var sacrifice_feedback: SacrificeFeedback

var card: CardRoot = null

func setup_from_card(source_card: CardRoot) -> void:
	card = source_card
	_setup_children()

func play_hover(value: bool) -> void:
	if hover_feedback != null:
		hover_feedback.play(value)

func play_select(value: bool) -> void:
	if select_feedback != null:
		select_feedback.play(value)

func play_placed() -> void:
	if position_feedback != null:
		position_feedback.reset()

func play_attack(context: AttackContext) -> void:
	if attack_feedback != null:
		await attack_feedback.play(context)

func play_hurt(context: DamageContext) -> void:
	if hurt_feedback != null:
		await hurt_feedback.play(context)

func play_death(context: DeathContext) -> void:
	if death_feedback != null:
		await death_feedback.play(context)

func play_sacrifice_idle() -> void:
	if sacrifice_feedback != null:
		sacrifice_feedback.play_idle()

func play_sacrifice_selected() -> void:
	if sacrifice_feedback != null:
		sacrifice_feedback.play_selected()

func play_sacrifice_committed() -> void:
	if sacrifice_feedback != null:
		sacrifice_feedback.play_committed()

func stop_sacrifice_feedback() -> void:
	if sacrifice_feedback != null:
		sacrifice_feedback.stop()

func _setup_children() -> void:
	for child in get_children():
		if child.has_method("setup_feedback_root"):
			child.setup_feedback_root(self)
