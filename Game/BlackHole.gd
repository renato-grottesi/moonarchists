extends StaticBody2D

export (float) var mass: float = 1.0
var com_rotation = 0

func _ready():
	$Sprite.scale = Vector2(mass,mass)
	$SpriteBack.scale = Vector2(mass,mass)
	$Shape.shape = CircleShape2D.new()
	$Shape.shape.radius = 30.0 * mass

func _process(delta):
	com_rotation += delta * 8
	var com_transform = Transform2D(com_rotation, Vector2(0, 0))
	$SpriteBack.transform = com_transform.scaled(Vector2(mass*3, mass * 0.20))

	var shake_amount = 10 * $ShakeTimer.time_left
	$Sprite.set_offset(Vector2(rand_range(-1.0, 1.0) * shake_amount, rand_range(-1.0, 1.0) * shake_amount))
	$SpriteBack.set_offset(Vector2(rand_range(-1.0, 1.0) * shake_amount, rand_range(-1.0, 1.0) * shake_amount))


func get_radius():
	return $Shape.shape.radius


func eat():
	$SwooshSound.play()
	$SwooshSound.set_volume_db(Global.get_sound_volume_db())
	$ShakeTimer.start()
