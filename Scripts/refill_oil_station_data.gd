extends Area2D

signal interacted_with

func _on_area_entered(area: Area2D) -> void:
	interacted_with.emit()
