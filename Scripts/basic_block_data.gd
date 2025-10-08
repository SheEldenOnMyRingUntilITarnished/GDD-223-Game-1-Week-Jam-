extends StaticBody2D

var mineable: bool
var value: int

func Mined():
	mineable = false
	value = 0
	$Sprite2D.set_frame(7)
	z_index = -100;
	$CollisionShape2D.queue_free()
