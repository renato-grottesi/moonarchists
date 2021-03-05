extends "res://Game/CelestialBody.gd"

export (Vector2) var impulse0: Vector2 = Vector2(0, 0)
export (Resource) var texture
export (bool) var friendly: bool = false
export (int) var moons_count: int = 0
export (int) var moons_max_offset: int = 20

signal damage
signal friendly_destroyed

const asteroid_scene = preload("res://Game/Asteroid.tscn")
const Asteroid = preload("res://Game/Asteroid.gd")
const BlackHole = preload("res://Game/BlackHole.gd")

var time = 0.0
var last_pos
const absorb_scale = 3.0


func _ready():
	apply_impulse(Vector2(0, 0), impulse0)
	angular_velocity = (1 + Global.rng.randf_range(0, 1)) * sign(Global.rng.randf_range(-1, 1))
	$Sprite.set_texture(texture)
	last_pos = global_position
	for i in range(0, moons_count):
		var asteroid = asteroid_scene.instance()
		var rad = i * (2 * PI / moons_count)
		var randoff = moons_max_offset * Global.rng.randf_range(0, 1)
		var offset = Global.rng.randf_range(0, 35) + (40 + randoff) * mass
		var pos = Vector2(offset * sin(rad), offset * cos(rad))
		asteroid.position = pos + global_position
		asteroid.speed = Global.rng.randf_range(0, 2) + 1
		asteroid.connect("damage", self, "on_asteroid_damage")
		$Satellites.add_child(asteroid)
	$Shape.shape = CircleShape2D.new()


func check_asteroids(bh):
	for S in $Satellites.get_children():
		if (S.position - bh.position).length() < bh.get_radius():
			bh.eat()
			S.queue_free()


func on_asteroid_damage():
	emit_signal("damage")


func _physics_process(delta):
	for S in $Satellites.get_children():
		S.position -= last_pos
		S.position = S.position.rotated(delta * S.speed)
		S.position += global_position
	last_pos = global_position


func _on_NeutralMoon_body_entered(body):
	if body is BlackHole:
		absorb()
		body.eat()
	else:
		emit_signal("damage")
		$Hit.start(0.5)
		if body is Asteroid:
			body.hit()


func _process(delta):
	update_shadow()
	var childs_scale = mass
	if ! ($Absorb.is_stopped()):
		childs_scale = $Absorb.time_left * absorb_scale
	$Sprite.scale = Vector2(childs_scale, childs_scale)
	$Shadow.scale = Vector2(childs_scale, childs_scale)
	$Shape.shape.radius = 30.0 * childs_scale
	var modulation = 1 - ($Hit.time_left * 2)
	$Sprite.set_modulate(Color(1, modulation, modulation, 1))


func get_radius():
	return $Shape.shape.radius


func absorb():
	if $Absorb.is_stopped():
		collision_layer = 0
		collision_mask = 0
		$Absorb.start(mass / absorb_scale)
		$Shape.disabled = true
		for S in $Satellites.get_children():
			S.absorb()


func _on_Absorb_timeout():
	if friendly:
		emit_signal("friendly_destroyed")
	queue_free()
