extends Node2D

export (int) var current_level: int = 0
export (int) var two_stars_requirements: int = 3
export (int) var three_stars_requirements: int = 1
export (int) var asteroids_count: int = 0
export (int) var asteroids_offset: int = 200

const mass_bullet_scene = preload("res://Game/MassBullet.tscn")
const star_texture = preload("res://Sprites/star_full.png")
const asteroid_scene = preload("res://Game/Asteroid.tscn")
const Asteroid = preload("res://Game/Asteroid.gd")
const opening_duration = 4
const bullet_speed_k = 14

var shoots = 0
var game_over = false

func _ready():
	Global.rng.seed = current_level
	if Global.is_speedrunning:
		$HUD/Score.text = Global.ms2str(Global.get_partial_speed_run())
	if ! Global.use_cross_hair:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$CrossHair.visible = Global.use_cross_hair && (OS.get_name() != "Android")
	var stars = Global.level_status[current_level - 1]
	if stars > 4:
		if $HUD/Opening/Label.text.length() > 0:
			if ! Global.is_speedrunning:
				if Global.use_joy_pad:
					$HUD/Opening/Label.text = $HUD/Opening/Label.text.replace("SHOOT", "Press A")
					$HUD/Opening/Label.text = $HUD/Opening/Label.text.replace("PROP", "Press B")
					$HUD/Opening/Label.text = $HUD/Opening/Label.text.replace("AIMING", "Move the joystick to aim.")
				elif OS.get_name() == "Android":
					$HUD/Opening/Label.text = $HUD/Opening/Label.text.replace("SHOOT", "Tap")
					$HUD/Opening/Label.text = $HUD/Opening/Label.text.replace("PROP", "Tap with two fingers")
					$HUD/Opening/Label.text = $HUD/Opening/Label.text.replace("AIMING", "")
				else:
					$HUD/Opening/Label.text = $HUD/Opening/Label.text.replace("SHOOT", "Click or press space")
					$HUD/Opening/Label.text = $HUD/Opening/Label.text.replace("PROP", "Right click or press C")
					$HUD/Opening/Label.text = $HUD/Opening/Label.text.replace("AIMING", "Move the mouse or \nuse the arrow keys to aim")
				$HUD/Opening.popup()
	for i in range(0, asteroids_count):
		var asteroid = asteroid_scene.instance()
		asteroid.speed = Global.rng.randf_range(0, 2) + 1
		var rad = i * (2 * PI / asteroids_count)
		var offset = asteroids_offset + Global.rng.randf_range(0, 64)
		var pos = Vector2(offset * sin(rad), offset * cos(rad))
		asteroid.position = pos
		$Asteroids.add_child(asteroid)
	for B in $Bodies.get_children():
		B.connect("damage", self, "shake_it")
		B.connect("friendly_destroyed", self, "friendly_destroyed")


func _process(delta):
	if Global.is_speedrunning:
		$HUD/Score.text = Global.ms2str(Global.get_partial_speed_run())
	if $HUD/Opening.visible:
		$HUD/Opening/Label.percent_visible = 1 - $HUD/Opening/Timer.time_left / opening_duration
	var enemies_left = 0
	for B in $Bodies.get_children():
		if ! B.friendly:
			enemies_left += 1
	if enemies_left < 1:
		if ! game_over:
			set_game_over()
			if ! $HUD/Lost.visible:
				if ! Global.is_speedrunning:
					$HUD/Victory.popup()
				elif current_level >= Global.last_level:
					$HUD/LastLevel.popup()
				else:
					goto_next_level()

	var shake_amount = 10 * $Camera/Shake.time_left
	$Camera.set_offset(Vector2(rand_range(-1.0, 1.0) * shake_amount, rand_range(-1.0, 1.0) * shake_amount))
	$CrossHair.global_position = get_global_mouse_position()


func _physics_process(delta):
	#TODO: Need to increase gravity with proximity...
	for A in $Asteroids.get_children():
		A.position = A.position.rotated(delta * A.speed)
	var bhs = $BlackHoles.get_children().size()
	for BH in $BlackHoles.get_children():
		for B in $Bodies.get_children():
			B.check_asteroids(BH)
			B.attract_to(BH.position, 1.0)
		for B in $Bullets.get_children():
			B.attract_to(BH.position, 1.0)
		$Moon.attract_to(BH.position, 1.0)
	for B in $Bullets.get_children():
		B.mass = 0.1
		# Bullets feel some planets' gravity to make it easier to hit them
		for P in $Bodies.get_children():
			B.attract_to(P.position, P.mass/10.0)
		B.mass = 1


func _input(event):
	if $HUD/Opening.visible:
		if Input.is_action_pressed("ui_accept"):
			$HUD/Opening/Timer.start(0.001)
	else:
		if Input.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Global.abort_speed_run()
			Global.current_level = 0
		elif Input.is_action_pressed("ui_retry"):
			retry_level()
		else:
			$Moon.process_input(event)


func _incr_shoots():
	if ! game_over:
		shoots += 1
		$HUD/MoonsCounter.moons = 10 - shoots
		if ! Global.is_speedrunning:
			$HUD/Score.text = "Shots: " + String(shoots)
		if shoots > 10 and ! game_over:
			set_game_over()
			if ! $HUD/Victory.visible:
				$HUD/Lost/Reason.text = "You run out of moons"
				if ! Global.is_speedrunning:
					$HUD/Lost.popup()
				else:
					retry_level()


func _on_Moon_shoot(moon_speed):
	if ! game_over:
		if shoots < 10:
			var mass_bullet_instance = mass_bullet_scene.instance()
			mass_bullet_instance.position = $Moon.position + moon_speed
			mass_bullet_instance.linear_velocity = moon_speed * bullet_speed_k
			mass_bullet_instance.connect("damage", self, "shake_it")
			$Bullets.add_child(mass_bullet_instance)
		_incr_shoots()


func _on_Moon_push():
	if ! game_over:
		_incr_shoots()


func _on_Moon_destroyed(swallowed):
	if ! game_over:
		set_game_over()
		shake_it()
		if ! $HUD/Victory.visible:
			if swallowed:
				$HUD/Lost/Reason.text = "Your moon was swallowed\nby the black hole"
			else:
				$HUD/Lost/Reason.text = "Your moon took\n too much damage"
			if ! Global.is_speedrunning:
				$HUD/Lost.popup()
			else:
				retry_level()


func _on_Moon_heath(health):
	if ! game_over:
		$HUD/HealthBar.health = health


func _on_CloseVictory_pressed():
	goto_next_level()
	beep()


func goto_next_level():
	if current_level < Global.last_level:
		Global.current_level = current_level + 1
	else:
		$HUD/LastLevel.popup()


func _on_LastLevelVictory_pressed():
	Global.current_level = 0
	beep()


func _on_CloseOpening_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$HUD/Opening.hide()
	beep()


func _on_LostQuit_pressed():
	Global.current_level = 0
	Global.abort_speed_run()
	beep()


func _on_Victory_about_to_show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var stars = Global.level_status[current_level - 1]
	# You get 1 star simply for completing the level alive
	var new_stars = 1
	if shoots < (two_stars_requirements + 1):
		new_stars = 2
	if shoots < (three_stars_requirements + 1):
		new_stars = 3
	# Calculate and assign the new number of stars
	if stars > 4:
		stars = 1
	if new_stars > stars:
		stars = new_stars
	Global.level_status[current_level - 1] = stars
	enable_star($HUD/Victory/Star1)
	if stars > 1:
		enable_star($HUD/Victory/Star2)
	if stars > 2:
		enable_star($HUD/Victory/Star3)
	if current_level < Global.last_level:
		if Global.level_status[current_level] > 6:
			Global.level_status[current_level] = 6


func enable_star(which_star):
	which_star.set_texture(star_texture)
	var tween = Tween.new()
	$HUD/Victory.add_child(tween)
	tween.interpolate_property(which_star, "scale", Vector2(0, 0), Vector2(2, 2), 1.0, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()


func _on_Lost_about_to_show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$HUD/Lost/LostRetry.grab_focus()


func _on_Retry_pressed():
	retry_level()
	beep()


func retry_level():
	var stars = Global.level_status[current_level - 1]
	if stars > 3:
		Global.level_status[current_level - 1] = 5
	Global.current_level = current_level


func shake_it():
	$ExplosionSound.play()
	$ExplosionSound.set_volume_db(Global.get_sound_volume_db())
	$Camera/Shake.start()
	Global.do_slowmo()


func _on_Opening_about_to_show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$HUD/Opening/Timer.start(opening_duration)


func beep():
	$Beep.play()
	$Beep.set_volume_db(Global.get_sound_volume_db())


func _on_QuitVictory_pressed():
	Global.current_level = 0
	Global.abort_speed_run()
	beep()


func _on_LastLevel_about_to_show():
	if Global.is_speedrunning:
		var time = Global.stop_speed_run()
		$HUD/LastLevel/SpeedrunScore.visible = true
		$HUD/LastLevel/SpeedrunScore.text = "Speedrun: " + Global.ms2str(time)


func friendly_destroyed():
	set_game_over()
	if ! $HUD/Victory.visible:
		$HUD/Lost/Reason.text = "A friendly moon\n has been destroyed"
		if ! Global.is_speedrunning:
			$HUD/Lost.popup()
		else:
			retry_level()


func set_game_over():
	game_over = true
	$HUD/MoonsCounter.game_over = true
