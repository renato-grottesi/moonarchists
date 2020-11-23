extends StaticBody2D

export (float) var speed : float = 1.0
signal damage()

var explosion_pos = Vector2(0, 0)
var done = false

func hit():
	if !done:
		done = true
		$Boom.play()
		$Boom.set_volume_db(Global.get_sound_volume_db())
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
	if done :
		position = explosion_pos
	if global_position.length() < 60 :
		hit()
