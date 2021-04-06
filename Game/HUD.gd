extends CanvasLayer

const opening_duration = 4
const input_disable_duration = 0.25

const star_texture = preload("res://Sprites/star_full.png")
const double_tap_texture = preload("res://Sprites/double_tap.png")
const triple_tap_texture = preload("res://Sprites/triple_tap.png")
const gamepad_button_texture = preload("res://Sprites/gamepad_button.png")
const left_click_texture = preload("res://Sprites/left_click.png")
const right_click_texture = preload("res://Sprites/right_click.png")
const space_bar_texture = preload("res://Sprites/space_bar.png")
const swipe_texture = preload("res://Sprites/swipe.png")
const tap_texture = preload("res://Sprites/tap.png")
const key_texture = preload("res://Sprites/key.png")


func _ready():
	if Global.is_speedrunning:
		$Score.text = Global.ms2str(Global.get_partial_speed_run())
	var stars = Global.level_status[Global.current_level - 1]
	if stars > 5:
		if $Opening/Label.text.length() > 0:
			if ! Global.is_speedrunning:
				if Global.use_joy_pad:
					$Opening/Label.text = $Opening/Label.text.replace("SHOOT", "Press A")
					$Opening/Label.text = $Opening/Label.text.replace("PROP", "Press B")
					$Opening/Label.text = $Opening/Label.text.replace("AIMING", "Move the joystick to aim.")
				elif OS.get_name() == "Android":
					$Opening/Label.text = $Opening/Label.text.replace("SHOOT", "Tap")
					$Opening/Label.text = $Opening/Label.text.replace("PROP", "Tap with two fingers")
					$Opening/Label.text = $Opening/Label.text.replace("AIMING", "")
				else:
					$Opening/Label.text = $Opening/Label.text.replace("SHOOT", "Click or press space")
					$Opening/Label.text = $Opening/Label.text.replace("PROP", "Right click or press C")
					$Opening/Label.text = $Opening/Label.text.replace("AIMING", "Move the mouse or \nuse the arrow keys to aim")
				$Opening.popup()


func _process(delta):
	if $Opening.visible:
		$Opening/Label.percent_visible = 1 - $Opening/Timer.time_left / opening_duration
	if Global.is_speedrunning:
		$Score.text = Global.ms2str(Global.get_partial_speed_run())
	$ShootSprite.rotation_degrees = 0
	$PropelSprite.rotation_degrees = 0
	$RestartSprite.rotation_degrees = 0
	$MenuSprite.rotation_degrees = 0
	$KeyControls.visible = false;
	if Global.use_joy_pad:
		$ShootSprite.set_texture(gamepad_button_texture)
		$PropelSprite.set_texture(gamepad_button_texture)
		$RestartSprite.set_texture(gamepad_button_texture)
		$MenuSprite.set_texture(gamepad_button_texture)
		$ShootSprite.rotation_degrees = 180
		$PropelSprite.rotation_degrees = 90
		$RestartSprite.rotation_degrees = 270
		$MenuSprite.rotation_degrees = 0
	elif OS.get_name() == "Android":
		$ShootSprite.set_texture(tap_texture)
		$PropelSprite.set_texture(swipe_texture)
		$RestartSprite.set_texture(triple_tap_texture)
		$MenuSprite.set_texture(double_tap_texture)
	else:
		$KeyControls.visible = true;
		$ShootSprite.set_texture(left_click_texture)
		$PropelSprite.set_texture(right_click_texture)
		$RestartSprite.set_texture(key_texture)
		$MenuSprite.set_texture(key_texture)
	if (Global.current_level < Global.enable_propulsion):
		$PropelSprite.visible = false
		$PropelLabel.visible = false
		$KeyControls/PropelSprite.visible = false
		$KeyControls/PropelLabel.visible = false
	if (Global.current_level == 1):
		$ShootSprite.modulate = Color(1, 0, 0)
		$ShootLabel.modulate = Color(1, 0, 0)
		$KeyControls/ShootSprite.modulate = Color(1, 0, 0)
	if (Global.current_level == Global.enable_propulsion):
		$PropelSprite.modulate = Color(1, 0, 0)
		$PropelLabel.modulate = Color(1, 0, 0)
		$KeyControls/PropelSprite.modulate = Color(1, 0, 0)
		$KeyControls/PropelLabel.modulate = Color(1, 0, 0)

func enable_star(which_star):
	which_star.set_texture(star_texture)
	var tween = Tween.new()
	$Victory.add_child(tween)
	tween.interpolate_property(which_star, "scale", Vector2(0, 0), Vector2(2, 2), 1.0, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()


func beep():
	$Beep.play()
	$Beep.set_volume_db(Global.get_sound_volume_db())


func goto_next_level():
	if Global.current_level < Global.last_level:
		Global.current_level = Global.current_level + 1
	else:
		$LastLevel.popup()


func _on_LastLevel_about_to_show():
	if Global.is_speedrunning:
		var time = Global.stop_speed_run()
		$LastLevel/SpeedrunScore.visible = true
		$LastLevel/SpeedrunScore.text = "Speedrun: " + Global.ms2str(time)
	$InputDisable.start(input_disable_duration)


func _on_Opening_about_to_show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Opening/Timer.start(opening_duration)
	$InputDisable.start(input_disable_duration)


func _on_Lost_about_to_show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Lost/LostRetry.grab_focus()
	$InputDisable.start(input_disable_duration)


func _on_Victory_about_to_show():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	enable_star($Victory/Star1)
	var stars = Global.level_status[Global.current_level - 1]
	if stars > 1:
		enable_star($Victory/Star2)
	if stars > 2:
		enable_star($Victory/Star3)
	if Global.current_level < Global.last_level:
		if Global.level_status[Global.current_level] > 6:
			Global.level_status[Global.current_level] = 6
	$InputDisable.start(input_disable_duration)


func _on_Retry_pressed():
	if $InputDisable.time_left == 0:
		Global.retry_level()
		beep()


func _on_QuitVictory_pressed():
	if $InputDisable.time_left == 0:
		Global.current_level = 0
		Global.abort_speed_run()
		beep()


func _on_LastLevelVictory_pressed():
	if $InputDisable.time_left == 0:
		Global.current_level = 0
		beep()


func _on_CloseOpening_pressed():
	if $InputDisable.time_left == 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$Opening.hide()
		beep()


func _on_LostQuit_pressed():
	if $InputDisable.time_left == 0:
		Global.current_level = 0
		Global.abort_speed_run()
		beep()


func _on_NextVictory_pressed():
	if $InputDisable.time_left == 0:
		goto_next_level()
		beep()
