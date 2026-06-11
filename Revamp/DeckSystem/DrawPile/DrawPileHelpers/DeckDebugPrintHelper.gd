extends RefCounted
class_name DeckDebugPrintHelper


func print_match_result(result: Dictionary, seed_value: int) -> void:
	if result.is_empty():
		print("Deck setup failed.")
		return

	print("MATCH SEED: ", seed_value)
	_print_cards("P1 STARTING HAND", result["p1_starting_hand"])
	_print_cards("P2 STARTING HAND", result["p2_starting_hand"])
	_print_cards("P1 REMAINING DRAW PILE", result["p1_draw_pile"])
	_print_cards("P2 REMAINING DRAW PILE", result["p2_draw_pile"])


func _print_cards(label: String, cards: Array) -> void:
	var names: Array[String] = []

	for card in cards:
		var card_data := card as CardData

		if card_data != null:
			names.append(card_data.name)

	print(label, ": ", names)
