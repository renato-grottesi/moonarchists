extends RigidBody2D

const gravity_k = 20


func attract_to(t_center, t_mass):
	var offset = Vector2(0, 0)
	var direction = t_center - position
	var dist = direction.length()
	# The following equation should use dist*dist and gravity_k should be 3000,
	# but it doesn't feel right.
	var force = direction * (gravity_k * mass * t_mass) / (dist)
	apply_impulse(offset, force)
