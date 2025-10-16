extends Area2D

signal interacted_with_oil_refill_station(bool)
var used: bool = false

func _on_area_entered(area: Area2D) -> void:
	interacted_with_oil_refill_station.emit(used)
	used = true
