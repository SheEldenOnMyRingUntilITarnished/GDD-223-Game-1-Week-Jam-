extends Label

func _on_player_update_money(value: int) -> void:
	text = str(value)
