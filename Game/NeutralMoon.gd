extends "res://Game/CelestialBody.gd"

export (Vector2) var impulse0 : Vector2 = Vector2(0, 0)
export (Resource) var texture

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	apply_impulse(Vector2(0, 0), impulse0);
	angular_velocity = (1 + rng.randf_range(0, 1)) * sign(rng.randf_range(-1, 1));
	$Sprite.set_texture(texture)
	pass
