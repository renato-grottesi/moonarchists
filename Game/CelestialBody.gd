extends RigidBody2D


func attract_to(center, scale):
	var offset = Vector2(0, 0)
	var force = (center - position) * scale
	apply_impulse(offset, force)


func update_shadow():
	var globpos = global_position.normalized()
	var shadow_rotation = 0
	if globpos.y < 0:
		globpos = globpos.rotated(PI)
		shadow_rotation = acos(globpos.dot(Vector2(1, 0))) - rotation + PI
	else:
		shadow_rotation = acos(globpos.dot(Vector2(1, 0))) - rotation
	var shadow_transform = Transform2D.IDENTITY
	shadow_transform = shadow_transform.translated(Vector2(0, -16.0 * mass))
	shadow_transform = shadow_transform.scaled(Vector2(1, 2))
	shadow_transform = shadow_transform.rotated(shadow_rotation)
	$Shadow.transform = shadow_transform
