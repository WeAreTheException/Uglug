extends RefCounted
class_name AttackStepFactory

static func base_forward() -> AttackStep:
	var step := AttackStep.new()
	step.setup_base(AttackEvents.FORWARD)
	return step

static func base_event(event: String) -> AttackStep:
	var step := AttackStep.new()
	step.setup_base(event)
	return step

static func mutation_event(event: String, runtime: MutationRuntime) -> AttackStep:
	var step := AttackStep.new()
	step.setup_mutation(event, runtime)
	return step
