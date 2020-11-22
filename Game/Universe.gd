extends Node2D

export (int) var current_level : int = 0
export (int) var next_level : int = 0
export (int) var asteroids_count : int = 0
export (int) var asteroids_offset : int = 200

var mass_bullet_scene = preload("res://Game/MassBullet.tscn")
var star_texture = preload("res://Sprites/star_full.png")
var asteroid_scene = preload("res://Game/Asteroid.tscn")
const Asteroid = preload("res://Game/Asteroid.gd")

var shoots = 0;
var game_over = false;

var rng = RandomNumberGenerator.new()
var com_rotation = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rng.randomize()
	var stars = Global.level_status[current_level-1]
	if stars > 5 :
		if $HUD/Opening/Label.text.length() > 1:
			$HUD/Opening.popup()
	for i in range(0, asteroids_count):
		var asteroid = asteroid_scene.instance();
		asteroid.speed = rng.randf_range(0, 2) + 1
		var rad = i*(2*PI/asteroids_count)
		var offset = asteroids_offset + rng.randf_range(0, 64)
		var pos = Vector2( offset*sin(rad), offset*cos(rad))
		asteroid.position = pos
		$Asteroids.add_child(asteroid);
	for B in $Bodies.get_children():
		B.connect("damage", self, "shake_it")
	pass

func _process(delta):
	com_rotation += delta * 8
	var com_transform = Transform2D(com_rotation, Vector2(0, 0))
	$CenterOfMass/SpriteBack.transform = com_transform.scaled(Vector2(3, 0.20))
	var enemies_left = 0
	for B in $Bodies.get_children():
		if ! B.friendly:
			enemies_left += 1
		var c = $CenterOfMass.position
		var b = B.position
		var l = b.distance_to(c)
		if l < 60.0:
			$ExplosionSound.play()
			$ExplosionSound.set_volume_db(Global.get_sound_volume_db())
			B.queue_free();
			shake_it()
			if B.friendly :
				game_over = true
				if ! $HUD/Victory.visible:
					$HUD/Lost.popup()
	if enemies_left < 1 :
		if !game_over:
			game_over = true
			if ! $HUD/Lost.visible:
				$HUD/Victory.popup()

	var shake_amount = 10 * $Camera/Shake.time_left
	$Camera.set_offset(Vector2( \
		rand_range(-1.0, 1.0) * shake_amount, \
		rand_range(-1.0, 1.0) * shake_amount \
	))

	pass

func _physics_process(delta):
	for B in $Bodies.get_children():
		B.attract_to($CenterOfMass.position, 0.1)
	for A in $Asteroids.get_children():
		A.position = A.position.rotated(delta*A.speed)
	for B in $Bullets.get_children():
		B.attract_to($CenterOfMass.position, 0.1)
		# Bullets feel planets' gragity to make it easier to hit them
		for P in $Bodies.get_children():
			B.attract_to(P.position, 0.01)
	$Moon.attract_to($CenterOfMass.position, 0.1)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Global.goto_scene(Global.levels[0])

func _on_Moon_shoot(moon_speed):
	if !game_over:
		var mass_bullet_instance = mass_bullet_scene.instance();
		mass_bullet_instance.position = $Moon.position + moon_speed
		mass_bullet_instance.linear_velocity = moon_speed * 10
		mass_bullet_instance.connect("damage", self, "shake_it")
		$Bullets.add_child(mass_bullet_instance);
		shoots += 1;
		$HUD/Score.text = "Shoots: " + String(shoots)
	pass

func _on_Moon_destroyed():
	if !game_over:
		game_over = true
		$ExplosionSound.play()
		$ExplosionSound.set_volume_db(Global.get_sound_volume_db())
		if ! $HUD/Victory.visible:
			$HUD/Lost.popup()
	pass

func _on_Moon_heath(health):
	if !game_over:
		$HUD/HealthBar.health = health;
	pass

func _on_CloseVictory_pressed():
	if next_level != 0 :
		Global.goto_scene(Global.levels[next_level])
	else:
		$HUD/LastLevel.popup()
	pass

func _on_LastLevelVictory_pressed():
	Global.goto_scene(Global.levels[next_level])
	pass

func _on_CloseOpening_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$HUD/Opening.hide()
	pass

func _on_LostQuit_pressed():
	Global.goto_scene(Global.levels[0])
	pass

func _on_Victory_about_to_show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
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
	pass

func _on_Lost_about_to_show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$HUD/Lost/LostRetry.grab_focus()
	pass

func _on_Retry_pressed():
	var stars = Global.level_status[current_level-1]
	if stars > 3 :
		Global.level_status[current_level-1] = 5
	Global.goto_scene(Global.levels[current_level])
	pass

func shake_it():
	$Camera/Shake.start()
	pass

func _on_Opening_about_to_show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass
