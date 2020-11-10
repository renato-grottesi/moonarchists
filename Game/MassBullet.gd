extends "res://Game/CelestialBody.gd"

func _ready():
	pass

func _on_Timer_timeout():
	queue_free()
	pass

func _on_MassBullet_body_entered(body):
	queue_free()
	pass
