extends StaticBody2D
export (float) var speed : float = 1.0
var explosion_pos = Vector2(0, 0)
var done = false

func hit():
	done = true
	$Boom.play()
	explosion_pos = global_position
	$Sprite.visible = false
	collision_layer = 0
	collision_mask = 0
	$Timer.start()
	$Explosion.restart()
	pass

func _on_Timer_timeout():
	queue_free()
	pass

func _process(delta):
	if done :
		position = explosion_pos
	pass
