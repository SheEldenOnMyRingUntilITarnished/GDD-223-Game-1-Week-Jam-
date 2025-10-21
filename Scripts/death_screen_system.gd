extends Node2D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta: float) -> void:
	$Camera2D/PointLight2D.global_position = get_global_mouse_position()
