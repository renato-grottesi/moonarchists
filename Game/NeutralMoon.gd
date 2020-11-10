extends "res://Game/CelestialBody.gd"

export (Vector2) var impulse0 : Vector2 = Vector2(0, 0)
export (Resource) var texture

func _ready():
	apply_impulse(Vector2(0, 0), impulse0);
	apply_torque_impulse(1000);
	$Sprite.set_texture(texture)
	pass

