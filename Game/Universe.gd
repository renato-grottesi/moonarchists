extends Node2D

export (int) var current_level : int = 0
export (int) var next_level : int = 0
export (int) var asteroids_count : int = 0
export (int) var asteroids_offset : int = 200

const mass_bullet_scene = preload("res://Game/MassBullet.tscn")
const star_texture = preload("res://Sprites/star_full.png")
const asteroid_scene = preload("res://Game/Asteroid.tscn")
const Asteroid = preload("res://Game/Asteroid.gd")
const opening_duration = 4
const gravity_k = 0.1
const bullet_speed_k = 12

var shoots = 0;
var game_over = false;
var rng = RandomNumberGenerator.new()

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
		B.connect("swoosh", self, "swoosh")

func _process(delta):
	if $HUD/Opening.visible:
		$HUD/Opening/Label.percent_visible = 1 - $HUD/Opening/Timer.time_left/opening_duration
	var enemies_left = 0
	for B in $Bodies.get_children():
		if ! B.friendly:
			enemies_left += 1
		var c = $BlackHole.position
		var b = B.position
		var l = b.distance_to(c)
		if l < 60.0:
			B.queue_free();
			swoosh()
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

func _physics_process(delta):
	for B in $Bodies.get_children():
		B.attract_to($BlackHole.position, gravity_k)
	for A in $Asteroids.get_children():
		A.position = A.position.rotated(delta*A.speed)
	for B in $Bullets.get_children():
		B.attract_to($BlackHole.position, gravity_k)
		# Bullets feel planets' gragity to make it easier to hit them
		for P in $Bodies.get_children():
			B.attract_to(P.position, gravity_k/10)
	$Moon.attract_to($BlackHole.position, gravity_k)

func _input(event):
	if $HUD/Opening.visible:
		if (event is InputEventMouseButton) or (event is InputEventKey):
			$HUD/Opening/Timer.start(0.001)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Global.goto_scene(Global.levels[0])

func _on_Moon_shoot(moon_speed):
	if !game_over:
		var mass_bullet_instance = mass_bullet_scene.instance();
		mass_bullet_instance.position = $Moon.position + moon_speed
		mass_bullet_instance.linear_velocity = moon_speed * bullet_speed_k
		mass_bullet_instance.connect("damage", self, "shake_it")
		mass_bullet_instance.connect("swoosh", self, "swoosh")
		$Bullets.add_child(mass_bullet_instance);
		shoots += 1;
		$HUD/Score.text = "Shoots: " + String(shoots)

func _on_Moon_destroyed():
	if !game_over:
		game_over = true
		shake_it()
		if ! $HUD/Victory.visible:
			$HUD/Lost.popup()

func _on_Moon_heath(health):
	if !game_over:
		$HUD/HealthBar.health = health;

func _on_CloseVictory_pressed():
	if next_level != 0 :
		Global.goto_scene(Global.levels[next_level])
	else:
		$HUD/LastLevel.popup()
	beep()

func _on_LastLevelVictory_pressed():
	Global.goto_scene(Global.levels[next_level])
	beep()

func _on_CloseOpening_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$HUD/Opening.hide()
	beep()

func _on_LostQuit_pressed():
	Global.goto_scene(Global.levels[0])
	beep()

func _on_Victory_about_to_show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var stars = Global.level_status[current_level-1]
	# You get 1 star simply for completing the level alive
	var new_stars = 1
	# You get 2 stars for using less than 4 shots
	if shoots < 4:
		new_stars = 2
	# You get all 3 stars only if you complete the level with 1 shot
	if shoots < 2:
		new_stars = 3
	# Calculate and assign the new number of stars
	if stars > 4 :
		stars = 1
	if new_stars > stars:
		stars = new_stars
	Global.level_status[current_level-1] = stars
	enable_star($HUD/Victory/Star1)
	if stars > 1 :
		enable_star($HUD/Victory/Star2)
	if stars > 2 :
		enable_star($HUD/Victory/Star3)
	if next_level > 0:
		if Global.level_status[next_level-1] > 6:
			Global.level_status[next_level-1] = 6

func enable_star(which_star):
	which_star.set_texture(star_texture)
	var tween = Tween.new()
	$HUD/Victory.add_child(tween)
	tween.interpolate_property(which_star, "scale", 
		Vector2(0, 0), Vector2(2, 2), 1.0, 
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()

func _on_Lost_about_to_show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$HUD/Lost/LostRetry.grab_focus()

func _on_Retry_pressed():
	var stars = Global.level_status[current_level-1]
	if stars > 3 :
		Global.level_status[current_level-1] = 5
	Global.goto_scene(Global.levels[current_level])
	beep()

func shake_it():
	$ExplosionSound.play()
	$ExplosionSound.set_volume_db(Global.get_sound_volume_db())
	$Camera/Shake.start()

func swoosh():
	$SwooshSound.play()
	$SwooshSound.set_volume_db(Global.get_sound_volume_db())
	$BlackHole.eat()

func _on_Opening_about_to_show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$HUD/Opening/Timer.start(opening_duration)

func beep():
	$Beep.play()
	$Beep.set_volume_db(Global.get_sound_volume_db())
