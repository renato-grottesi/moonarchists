extends Node2D

export (int) var current_level : int = 0
export (int) var next_level : int = 0

var mass_bullet_scene = preload("res://Game/MassBullet.tscn")
var star_texture = preload("res://Sprites/star_full.png")

var shoots = 0;
var game_over = false;

func _ready():
	var stars = Global.level_status[current_level-1]
	if stars > 5 :
		if $HUD/Opening/Label.text.length() > 1:
			$HUD/Opening.popup()
	pass

func _process(delta):
	var enemies_left = 0
	for B in $Bodies.get_children():
		if ! B.friendly:
			enemies_left += 1
		var c = $CenterOfMass.position
		var b = B.position
		var l = b.distance_to(c)
		if l < 60.0:
			$ExplosionSound.play()
			B.queue_free();
			if B.friendly :
				game_over = true
				$HUD/Lost.popup()
	if enemies_left < 1 :
		if !game_over:
			game_over = true
			$HUD/Victory/Star1.set_texture(star_texture)
			$HUD/Victory.popup()
	pass

func _physics_process(delta):
	for B in $Bodies.get_children():
		B.attract_to($CenterOfMass.position, 0.1)
	for B in $Bullets.get_children():
		B.attract_to($CenterOfMass.position, 0.1)
		# Bullets feel planets' gragity to make it easier to hit them
		for P in $Bodies.get_children():
			B.attract_to(P.position, 0.01)
	$Moon.attract_to($CenterOfMass.position, 0.1)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			Global.goto_scene(Global.levels[0])

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
		$ExplosionSound.play()
		$HUD/Lost.popup()
	pass

func _on_Moon_heath(health):
	if !game_over:
		$HUD/Health.value = health;
	pass

func _on_CloseVictory_pressed():
	if next_level != 0 :
		Global.goto_scene(Global.levels[next_level])
	else:
		$HUD/LastLevel.popup()
	pass

func _on_LostRetry_pressed():
	var stars = Global.level_status[current_level-1]
	if stars > 3 :
		Global.level_status[current_level-1] = 5
	Global.goto_scene(Global.levels[current_level])
	pass

func _on_LastLevelVictory_pressed():
	Global.goto_scene(Global.levels[next_level])
	pass

func _on_CloseOpening_pressed():
	$HUD/Opening.hide()
	pass

func _on_LostQuit_pressed():
	Global.goto_scene(Global.levels[0])
	pass

func _on_Victory_about_to_show():
	var stars = Global.level_status[current_level-1]
	var new_stars = 1
	if shoots < 3:
		new_stars = 2
	if shoots < 2:
		new_stars = 3
	if stars > 4 :
		stars = 1
	if new_stars > stars:
		stars = new_stars
	Global.level_status[current_level-1] = stars
	$HUD/Victory/Star1.set_texture(star_texture)
	if stars > 1 :
		$HUD/Victory/Star2.set_texture(star_texture)
	if stars > 2 :
		$HUD/Victory/Star3.set_texture(star_texture)
	if next_level > 0:
		if Global.level_status[next_level-1] > 6:
			Global.level_status[next_level-1] = 6
	pass # Replace with function body.


func _on_Lost_about_to_show():
	$HUD/Lost/LostRetry.grab_focus()
	pass
