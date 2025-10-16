extends Node2D

@onready var start_button: Button = $Start_Button
@onready var quit_button: Button = $Quit_Button

func _ready() -> void:
	$AnimationPlayer.play("Main_Menu_Falling")


func _on_start_button_pressed() -> void:
	$AnimationPlayer.play("Start_Game")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Start_Game":
		get_tree().change_scene_to_file("res://Scenes/main_game.tscn")
