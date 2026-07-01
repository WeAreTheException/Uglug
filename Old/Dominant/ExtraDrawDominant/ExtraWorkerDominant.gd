extends Dominant
class_name ExtraWorkerDominant

@export var extra_worker_draw_amount: int = 1

func on_round_draw_phase(dominant_root: DominantRoot, round_number: int) -> void:
	if round_number != 2:
		return

	dominant_root.draw_worker_cards_from_dominant(extra_worker_draw_amount)
