extends Camera2D


func _on_player_update_camera(size: int) -> void:
	zoom = Vector2(size,size)


func _on_menu_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_game.tscn")


func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
