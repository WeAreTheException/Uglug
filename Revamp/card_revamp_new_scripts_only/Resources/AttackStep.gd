extends Resource
class_name AttackStep

@export var attack_event: String = AttackEvents.FORWARD
@export var source_type: String = AttackStepSourceTypes.BASE

var source_runtime: MutationRuntime = null
var source_mutation: Mutation = null
var is_base_step: bool = true

func setup_base(event: String) -> void:
	attack_event = event
	source_type = AttackStepSourceTypes.BASE
	is_base_step = true

func setup_mutation(event: String, runtime: MutationRuntime) -> void:
	attack_event = event
	source_type = AttackStepSourceTypes.MUTATION
	source_runtime = runtime
	is_base_step = false
	if runtime != null:
		source_mutation = runtime.mutation
