extends Control

const story_duration = 8
const lock_texture = preload("res://Sprites/lock.png")

var click_start;

func _ready():
	$Play.grab_focus()
	fullscreen_text()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	if $StoryIntro.visible:
		$StoryIntro/Label.percent_visible = 1 - $StoryIntro/Timer.time_left/story_duration

func _input(event):
	if $StoryIntro.visible:
		if (event is InputEventMouseButton) or (event is InputEventKey):
			$StoryIntro/Timer.start(0.001)

func _unhandled_input(event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event is InputEventJoypadButton:
		Global.use_joy_pad = true
		Global.use_cross_hair = false

func _on_exit_pressed():
	beep()
	get_tree().quit()

func _on_play_pressed():
	if Global.level_status[0] < 6:
		$Levels.popup()
	else:
		$StoryIntro.popup()
	beep()

func _on_Options_pressed():
	$OptionsDialog.popup()
	beep()

func _on_CloseCreditsDialog_pressed():
	$CreditsDialog.hide()
	beep()

func _on_Credits_pressed():
	$CreditsDialog.popup()
	beep()

func _on_CloseOptionsDialog_pressed():
	$OptionsDialog.hide()
	$Options.grab_focus()
	beep()

func _on_CloseLevelsDialog_pressed():
	$Levels.hide()
	$Play.grab_focus()
	beep()

func _on_SoundSlider_value_changed(value):
	Global.set_sound_volume(value)
	beep()

func _on_MusicSlider_value_changed(value):
	Global.set_music_volume(value)

func _on_OptionsDialog_about_to_show():
	$OptionsDialog/SoundSlider.value = Global.get_sound_volume()
	$OptionsDialog/MusicSlider.value = Global.get_music_volume()
	$OptionsDialog/CloseOptionsDialog.grab_focus()
	$OptionsDialog/CrosshairAim.visible = OS.get_name() != "Android"
	$OptionsDialog/FullScreen.visible = OS.get_name() != "Android"
	$OptionsDialog/ToggleFullScreen.visible = OS.get_name() != "Android"
	$OptionsDialog/ToggleCrosshair.visible = OS.get_name() != "Android"
	fullscreen_text()
	crosshair_text()

func _on_OptionsDialog_popup_hide():
	# Save the sound and music volumes
	Global.save_game()
	$Options.grab_focus()

func _on_ToggleFullScreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
	fullscreen_text()
	beep()

func fullscreen_text():
	if OS.window_fullscreen:
		$OptionsDialog/ToggleFullScreen.text = "ON"
	else:
		$OptionsDialog/ToggleFullScreen.text = "OFF"

func crosshair_text():
	if Global.use_cross_hair:
		$OptionsDialog/ToggleCrosshair.text = "ON"
	else:
		$OptionsDialog/ToggleCrosshair.text = "OFF"

func _on_CloseStoryDialog_pressed():
	$StoryIntro.hide()
	$Levels.popup()
	beep()

func _on_StoryIntro_about_to_show():
	$StoryIntro/Timer.start(story_duration)

func beep():
	$Beep.play()
	$Beep.set_volume_db(Global.get_sound_volume_db())

func _on_Levels_popup_hide():
	$Play.grab_focus()

func _on_ToggleCrosshair_pressed():
	Global.use_cross_hair = !Global.use_cross_hair
	crosshair_text()

func _on_CloseHelpDialog_pressed():
	$HelpDialog.hide()

func _on_Help_pressed():
	$HelpDialog.popup()

func _on_SpeedRun_pressed():
	if Global.get_total_stars() > 15:
		Global.start_speed_run()
		Global.goto_scene(Global.levels[1])

func _on_Levels_about_to_show():
	if Global.get_total_stars() < 16:
		$Levels/SpeedRun.text = String(Global.get_total_stars()) + "/16 STARS"
		$Levels/SpeedRun.icon = lock_texture
	else:
		$Levels/SpeedRun.text = "Speedrun"
	if Global.speed_run_record > 0:
		$Levels/SpeedRun.text = "Speedrun: " + Global.ms2str(Global.speed_run_record)
	$Levels/Level1.grab_focus()
