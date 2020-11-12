extends "res://Game/CelestialBody.gd"
var done = false
var explosion_pos = Vector2(0, 0)

func _ready():
	pass

func _on_Timer_timeout():
	queue_free()
	pass

func _physics_process(delta):
	if done :
		position = explosion_pos
		linear_velocity = Vector2(0, 0)
		angular_velocity = 0
	pass

func _on_MassBullet_body_entered(body):
	done = true
	$ExplosionSound.play()
	explosion_pos = position
	$Sprite.visible = false
	collision_layer = 0
	collision_mask = 0
	$Timer.start()
	$Explosion.restart()
	pass
