extends RigidBody2D

func _ready():
	apply_impulse(Vector2(0, 0), Vector2(0, 500));
	apply_torque_impulse(1000);
	pass

func attract_to(center, scale):
	var offset = Vector2(0, 0);
	var force = (center - position) * scale;
	apply_impulse(offset, force);
