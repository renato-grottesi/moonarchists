extends "res://Game/CelestialBody.gd"

export (bool) var is_asteroid : bool = false
signal damage()

const asteroid_texture = preload("res://Sprites/asteroid.png")
const Asteroid = preload("res://Game/Asteroid.gd")

var done = false
var explosion_pos = Vector2(0, 0)

func _ready():
	if !is_asteroid:
		$ShootSound.play()
		$ShootSound.set_volume_db(Global.get_sound_volume_db())
	else:
		$Sprite.set_texture(asteroid_texture)

func _on_Timer_timeout():
	queue_free()

func _physics_process(delta):
	if done :
		position = explosion_pos
		linear_velocity = Vector2(0, 0)
		angular_velocity = 0

func _on_MassBullet_body_entered(body):
	if body is Asteroid:
		body.hit()
	done = true
	$ExplosionSound.play()
	$ExplosionSound.set_volume_db(Global.get_sound_volume_db())
	explosion_pos = position
	$Sprite.visible = false
	collision_layer = 0
	collision_mask = 0
	$Timer.start()
	$Explosion.restart()
	emit_signal("damage")
