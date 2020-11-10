extends RigidBody2D

func attract_to(center, scale):
	var offset = Vector2(0, 0);
	var force = (center - position) * scale;
	apply_impulse(offset, force);
