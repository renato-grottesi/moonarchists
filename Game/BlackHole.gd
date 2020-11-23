extends StaticBody2D

var com_rotation = 0

func _ready():
	pass

func _process(delta):
	com_rotation += delta * 8
	var com_transform = Transform2D(com_rotation, Vector2(0, 0))
	$SpriteBack.transform = com_transform.scaled(Vector2(3, 0.20))

	var shake_amount = 10 * $ShakeTimer.time_left
	$Sprite.set_offset(Vector2( \
		rand_range(-1.0, 1.0) * shake_amount, \
		rand_range(-1.0, 1.0) * shake_amount \
	))
	$SpriteBack.set_offset(Vector2( \
		rand_range(-1.0, 1.0) * shake_amount, \
		rand_range(-1.0, 1.0) * shake_amount \
	))

func eat():
	$ShakeTimer.start()
	pass
