extends Node2D

export (int) var current_level : int = 0
export (int) var next_level : int = 0

var mass_bullet_scene = preload("res://Game/MassBullet.tscn");

var levels = [ "res://Scenes/MainMenu.tscn", "res://Game/Level01.tscn", "res://Game/Level02.tscn" ];

func _ready():
	pass

func _process(delta):
	for B in $Bodies.get_children():
		var c = $CenterOfMass.position
		var b = B.position
		var l = b.distance_to(c)
		if l < 60.0:
			B.queue_free();
	if $Bodies.get_child_count() < 1 :
		Global.goto_scene(levels[next_level])
	pass

func _physics_process(delta):
	for B in $Bodies.get_children():
		B.attract_to($CenterOfMass.position, 0.1)
	for B in $Bullets.get_children():
		B.attract_to($CenterOfMass.position, 0.1)
	$Moon.attract_to($CenterOfMass.position, 0.1)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			Global.goto_scene(levels[0])

func _on_Moon_shoot(moon_speed):
	var mass_bullet_instance = mass_bullet_scene.instance();
	mass_bullet_instance.position = $Moon.position + moon_speed
	mass_bullet_instance.linear_velocity = moon_speed * 10
	$Bullets.add_child(mass_bullet_instance);
	pass

func _on_Moon_destroyed():
	Global.goto_scene(levels[current_level])
	pass
