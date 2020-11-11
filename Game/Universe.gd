extends Node2D

export (int) var current_level : int = 0
export (int) var next_level : int = 0

var mass_bullet_scene = preload("res://Game/MassBullet.tscn");

var levels = [
	"res://Scenes/MainMenu.tscn",
	"res://Game/Level01.tscn",
	"res://Game/Level02.tscn",
	"res://Game/Level03.tscn"
	];

var shoots = 0;
var game_over = false;

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
		if !game_over:
			game_over = true
			$HUD/Victory.popup()
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
	if !game_over:
		var mass_bullet_instance = mass_bullet_scene.instance();
		mass_bullet_instance.position = $Moon.position + moon_speed
		mass_bullet_instance.linear_velocity = moon_speed * 10
		$Bullets.add_child(mass_bullet_instance);
		shoots += 1;
		$HUD/Score.text = "Shoots: " + String(shoots)
	pass

func _on_Moon_destroyed():
	if !game_over:
		game_over = true
		$HUD/Lost.popup()
	pass

func _on_Moon_heath(health):
	if !game_over:
		$HUD/Health.value = health;
	pass

func _on_CloseVictory_pressed():
	if next_level != 0 :
		Global.goto_scene(levels[next_level])
	else:
			$HUD/LastLevel.popup()
	pass

func _on_LostRetry_pressed():
	Global.goto_scene(levels[current_level])
	pass

func _on_LastLevelVictory_pressed():
	Global.goto_scene(levels[next_level])
	pass
