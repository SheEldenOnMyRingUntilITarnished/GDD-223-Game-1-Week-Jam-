extends Camera2D


func _on_player_update_camera(size: int) -> void:
	zoom = Vector2(size,size)
