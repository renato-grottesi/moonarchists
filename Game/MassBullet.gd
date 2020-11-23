extends "res://Game/CelestialBody.gd"

signal damage()
signal swoosh()

const asteroid_texture = preload("res://Sprites/asteroid.png")
const Asteroid = preload("res://Game/Asteroid.gd")
const BlackHole = preload("res://Game/BlackHole.gd")

var done = false
var explosion_pos = Vector2(0, 0)

func _ready():
	$ShootSound.play()
	$ShootSound.set_volume_db(Global.get_sound_volume_db())

func _on_Timer_timeout():
	queue_free()

func _physics_process(delta):
	if done :
		position = explosion_pos
		linear_velocity = Vector2(0, 0)
		angular_velocity = 0

func _on_MassBullet_body_entered(body):
	done = true
	explosion_pos = position
	$Sprite.visible = false
	collision_layer = 0
	collision_mask = 0
	if body is Asteroid:
		body.hit()
	if body is BlackHole:
		queue_free()
		emit_signal("swoosh")
	else:
		$Timer.start()
		$Explosion.restart()
		emit_signal("damage")
