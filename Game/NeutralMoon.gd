extends "res://Game/CelestialBody.gd"

export (Vector2) var impulse0 : Vector2 = Vector2(0, 0)
export (Resource) var texture
export (bool) var friendly : bool = false
export (int) var asteroids_count : int = 0

signal damage()

var asteroid_scene = preload("res://Game/Asteroid.tscn")
const Asteroid = preload("res://Game/Asteroid.gd")
var time = 0.0
var last_pos

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	apply_impulse(Vector2(0, 0), impulse0);
	angular_velocity = (1 + rng.randf_range(0, 1)) * sign(rng.randf_range(-1, 1));
	$Sprite.set_texture(texture)
	last_pos = global_position
	for i in range(0, asteroids_count):
		var asteroid = asteroid_scene.instance();
		var rad = i*(2*PI/asteroids_count)
		var offset = rng.randf_range(0, 40) + 60
		var pos = Vector2( offset*sin(rad), offset*cos(rad))
		asteroid.position = pos + global_position
		asteroid.speed = rng.randf_range(0, 2) + 1
		asteroid.connect("damage", self, "on_asteroid_damage")
		$Satellites.add_child(asteroid);
	pass

func on_asteroid_damage():
	emit_signal("damage")

func _physics_process(delta):
	for S in $Satellites.get_children():
		S.position -= last_pos
		S.position = S.position.rotated(delta*S.speed)
		S.position += global_position
	last_pos = global_position

func _on_NeutralMoon_body_entered(body):
	emit_signal("damage")
	if body is Asteroid:
		body.hit()
	pass
