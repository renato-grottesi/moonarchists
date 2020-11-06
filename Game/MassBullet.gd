extends RigidBody2D

func _ready():
	pass

func attract_to(center, scale):
	var offset = Vector2(0, 0);
	var force = (center - position) * scale;
	apply_impulse(offset, force);

func _on_Timer_timeout():
	queue_free()
	pass

func _on_MassBullet_body_entered(body):
	queue_free()
	pass
