extends "res://Game/CelestialBody.gd"

signal shoot(moon_speed)
signal destroyed()
signal heath(health)

export (Vector2) var impulse0 : Vector2 = Vector2(0, 0)

const MassBullet = preload("res://Game/MassBullet.gd")

var health = 100;

func _ready():
	apply_impulse(Vector2(0, 0), impulse0);
	emit_signal("heath", health)
	pass

func _physics_process(delta):
	rotation = 0

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			$SpriteNozzle.rotation_degrees += 3;
		if event.button_index == BUTTON_WHEEL_DOWN:
			$SpriteNozzle.rotation_degrees -= 3;
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				emit_signal("shoot", Vector2(60, 0).rotated($SpriteNozzle.rotation))
	if event is InputEventMouseMotion:
		$SpriteNozzle.rotation_degrees += event.relative.y;
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_LEFT:
			$SpriteNozzle.rotation_degrees -= 3;
		if event.pressed and event.scancode == KEY_RIGHT:
			$SpriteNozzle.rotation_degrees += 3;
		if event.pressed and event.scancode == KEY_UP:
			$SpriteNozzle.rotation_degrees -= 3;
		if event.pressed and event.scancode == KEY_DOWN:
			$SpriteNozzle.rotation_degrees += 3;
		if event.pressed and event.scancode == KEY_SPACE:
			emit_signal("shoot", Vector2(60, 0).rotated($SpriteNozzle.rotation))

func _on_Moon_body_entered(body):
	if body is MassBullet:
		health -= 25;
		emit_signal("heath", health)
		if health < 1:
			emit_signal("destroyed")
	else:
		emit_signal("destroyed")
	pass
