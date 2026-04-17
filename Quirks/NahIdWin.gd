extends CardQuirk
class_name NahIdWin

func on_before_take_damage(card: Card, attacker: Card, amount: int) -> int:
	if card == null:
		return amount

	if attacker == null:
		return amount

	if card.nah_id_win_used:
		return amount

	card.nah_id_win_used = true
	print(card.card_name, " NahIdWin blocked the damage")
	return 0
