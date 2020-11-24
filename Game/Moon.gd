extends "res://Game/CelestialBody.gd"

export (Vector2) var impulse0 : Vector2 = Vector2(0, 0)

signal shoot(moon_speed)
signal destroyed()
signal heath(health)
signal damage()

const MassBullet = preload("res://Game/MassBullet.gd")
const NeutralMoon = preload("res://Game/NeutralMoon.gd")
const Asteroid = preload("res://Game/Asteroid.gd")

var health = 100;

func _ready():
	apply_impulse(Vector2(0, 0), impulse0);
	emit_signal("heath", health)

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
		health -= 20;
		emit_signal("damage")
	elif body is NeutralMoon:
		health -= 30;
		emit_signal("damage")
	elif body is Asteroid:
		health -= 15;
		body.hit()
		emit_signal("damage")
	else:
		health = 0;
	if health <= 0:
		health = 0
	emit_signal("heath", health)
	if health < 1:
		$SpriteMoon.visible = false;
		$SpriteNozzle.visible = false;
		collision_layer = 0
		collision_mask = 0
		emit_signal("destroyed")

func _process(delta):
	update_shadow()
