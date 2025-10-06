extends StaticBody2D

var minedTexture: Texture

var mineable: bool
var value: int

func Mined():
	mineable = false
	value = 0
	$Sprite2D.texture = minedTexture
	$CollisionShape2D.queue_free()
