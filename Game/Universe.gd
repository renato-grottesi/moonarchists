extends Node2D

var click_start = Vector2(0, 0);
var mass_bullet_scene = preload("res://Game/MassBullet.tscn");

func _ready():
	pass

func _process(delta):
	for B in $Bodies.get_children():
		var c = $CenterOfMass.position
		var b = B.position
		var l = b.distance_to(c)
		if l < 60.0:
			Global.goto_scene("res://Scenes/MainMenu.tscn")
	pass

func _physics_process(delta):
	for B in $Bodies.get_children():
		B.attract_to($CenterOfMass.position, 0.1)
	for B in $Bullets.get_children():
		B.attract_to($CenterOfMass.position, 0.1)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				click_start = get_global_mouse_position();
			else:
				var mass_bullet_instance = mass_bullet_scene.instance();
				mass_bullet_instance.position = click_start
				mass_bullet_instance.linear_velocity = click_start - get_global_mouse_position();
				$Bullets.add_child(mass_bullet_instance);
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			Global.goto_scene("res://Scenes/MainMenu.tscn")
