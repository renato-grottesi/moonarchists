extends "res://Game/CelestialBody.gd"

export (Vector2) var impulse0 : Vector2 = Vector2(0, 0)

signal shoot(moon_speed)
signal destroyed(swallowed)
signal heath(health)
signal damage()

const MassBullet = preload("res://Game/MassBullet.gd")
const NeutralMoon = preload("res://Game/NeutralMoon.gd")
const Asteroid = preload("res://Game/Asteroid.gd")

var health = 100
var time = 0

func _ready():
	apply_impulse(Vector2(0, 0), impulse0);
	emit_signal("heath", health)
	$SpriteNozzle.visible = OS.get_name() != "Android" || Global.use_joy_pad

func _physics_process(delta):
	rotation = 0

func set_nozzle(pos):
	if pos.y < 0 :
		pos = pos.rotated(PI)
		$SpriteNozzle.rotation = acos(pos.dot(Vector2(1, 0))) - rotation + PI
	else:
		$SpriteNozzle.rotation = acos(pos.dot(Vector2(1, 0))) - rotation

func update_nozzle():
	if Global.use_cross_hair:
		var globpos = (get_global_mouse_position() - global_position).normalized()
		set_nozzle(globpos)
	if Global.use_joy_pad:
		var joypos = Vector2(Input.get_joy_axis(0,0), Input.get_joy_axis(0,1))
		if joypos.length() > 0.75:
			joypos = joypos.normalized()
			set_nozzle(joypos)

func _unhandled_input(event):
	update_nozzle()
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			$SpriteNozzle.rotation_degrees += 3;
		if event.button_index == BUTTON_WHEEL_DOWN:
			$SpriteNozzle.rotation_degrees -= 3;
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				emit_signal("shoot", Vector2(60, 0).rotated($SpriteNozzle.rotation))
	if event is InputEventMouseMotion:
		if !Global.use_cross_hair:
			$SpriteNozzle.rotation_degrees += event.relative.y
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_UP:
			$SpriteNozzle.rotation_degrees -= 3;
		if event.pressed and event.scancode == KEY_DOWN:
			$SpriteNozzle.rotation_degrees += 3;
		if event.pressed and event.scancode == KEY_SPACE and !event.echo :
			emit_signal("shoot", Vector2(60, 0).rotated($SpriteNozzle.rotation))
	if event is InputEventJoypadButton:
		if event.is_pressed() && event.button_index == 0 && Global.use_joy_pad:
			emit_signal("shoot", Vector2(60, 0).rotated($SpriteNozzle.rotation))
		Global.use_joy_pad = true
		Global.use_cross_hair = false
		$SpriteNozzle.visible = true
#		print("JOYSTICK BUTTON: " + String(event.button_index))
#	if event is InputEventJoypadMotion:
#		print("JOYSTICK AXIS: " + String(event.axis) + ", VALUE: " + String(event.axis_value))

func _on_Moon_body_entered(body):
	var swallowed = false
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
		swallowed = true
		health = 0;
	if health <= 0:
		health = 0
	emit_signal("heath", health)
	if health < 1:
		$SpriteMoon.visible = false;
		$SpriteNozzle.visible = false;
		collision_layer = 0
		collision_mask = 0
		emit_signal("destroyed", swallowed)

func _process(delta):
	update_nozzle()
	update_shadow()
	time+=delta
	$Outline.material.set_shader_param("time", time);
