extends StaticBody2D

var minedTexture = load("res://Block Sprites.png")

var mineable: bool
var value: int

func Mined():
	mineable = false
	value = 0
	$Sprite2D.texture = minedTexture
	$Sprite2D.set_frame(2)
	z_index = -100;
	$CollisionShape2D.queue_free()
	
