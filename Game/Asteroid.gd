extends StaticBody2D

export (float) var speed: float = 1.0
signal damage

var explosion_pos = Vector2(0, 0)
var done = false
var rotation_speed = 0.0


func _ready():
	rotation_speed = Global.rng.randf_range(5, 10)
	if Global.rng.randf_range(-1, 1) > 0.0:
		rotation_speed = -rotation_speed
	var randscale = Vector2(Global.rng.randf_range(0.4, 1.2), Global.rng.randf_range(0.4, 1.2))
	$Sprite.scale = randscale
	var grey = Global.rng.randf_range(0.25, 1.0)
	$Sprite.modulate = Color(grey, grey, grey)


func hit():
	if ! done:
		done = true
		explosion_pos = global_position
		$Sprite.visible = false
		collision_layer = 0
		collision_mask = 0
		$Timer.start()
		$Explosion.restart()
		emit_signal("damage")


func _on_Timer_timeout():
	queue_free()


func _process(delta):
	if done:
		position = explosion_pos
	$Sprite.rotation += delta * rotation_speed

func absorb():
	collision_layer = 0
	collision_mask = 0
	$Shape.disabled = true
