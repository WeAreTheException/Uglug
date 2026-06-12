extends Node
class_name AttackExchangeRunner

signal exchange_started(exchange: AttackExchangeContext)
signal exchange_hit(exchange: AttackExchangeContext)
signal exchange_finished(exchange: AttackExchangeContext)

@export var impact_handler: AttackImpactHandler

var is_resolving := false
var active_exchange: AttackExchangeContext = null


func setup(direct_damage_router: DirectDamageRouter) -> void:
	if impact_handler == null:
		return

	impact_handler.setup(direct_damage_router)

	if not impact_handler.attack_hit.is_connected(_on_impact_attack_hit):
		impact_handler.attack_hit.connect(_on_impact_attack_hit)


func build_exchange(context: AttackContext) -> AttackExchangeContext:
	var exchange := AttackExchangeContext.new()
	exchange.setup_from_attack_context(context)
	return exchange


func resolve_exchange(exchange: AttackExchangeContext) -> void:
	if exchange == null:
		return

	if is_resolving:
		return

	if not _can_resolve(exchange):
		return

	is_resolving = true
	active_exchange = exchange

	exchange.commit_hit()
	exchange_started.emit(exchange)

	await _resolve_impact(exchange)
	_sync_pending_death_state(exchange)

	exchange_finished.emit(exchange)

	active_exchange = null
	is_resolving = false


func _can_resolve(exchange: AttackExchangeContext) -> bool:
	if impact_handler == null:
		print("exchange blocked: impact_handler missing")
		return false

	if exchange.attack_context == null:
		print("exchange blocked: attack_context missing")
		return false

	if exchange.attacker_card == null:
		print("exchange blocked: attacker missing")
		return false

	if not is_instance_valid(exchange.attacker_card):
		print("exchange blocked: attacker invalid")
		return false

	return true


func _resolve_impact(exchange: AttackExchangeContext) -> void:
	await impact_handler.handle_impact(
		exchange.attack_context,
		exchange.attacker_card
	)


func _sync_pending_death_state(exchange: AttackExchangeContext) -> void:
	if _is_card_pending_dead(exchange.attacker_card):
		exchange.mark_attacker_pending_death()

	if _is_card_pending_dead(exchange.target_card):
		exchange.mark_target_pending_death()


func _is_card_pending_dead(card: CardRoot) -> bool:
	if card == null:
		return false

	if not is_instance_valid(card):
		return true

	if card.stats == null:
		return false

	return card.stats.is_dead()


func _on_impact_attack_hit(context: AttackContext) -> void:
	if active_exchange == null:
		return

	if active_exchange.attack_context != context:
		return

	exchange_hit.emit(active_exchange)
