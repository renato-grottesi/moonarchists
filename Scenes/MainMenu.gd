extends Control

const story_duration = 8

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
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()

func _on_exit_pressed():
	get_tree().quit()

func _on_play_pressed():
	if Global.level_status[0] < 6:
		$Levels.popup()
	else:
		$StoryIntro.popup()

func _on_Options_pressed():
	$OptionsDialog.popup()

func _on_CloseCreditsDialog_pressed():
	$CreditsDialog.hide()

func _on_Credits_pressed():
	$CreditsDialog.popup()

func _on_CloseOptionsDialog_pressed():
	$OptionsDialog.hide()

func _on_CloseLevelsDialog_pressed():
	$Levels.hide()

func _on_SoundSlider_value_changed(value):
	Global.set_sound_volume(value)

func _on_MusicSlider_value_changed(value):
	Global.set_music_volume(value)

func _on_OptionsDialog_about_to_show():
	$OptionsDialog/SoundSlider.value = Global.get_sound_volume()
	$OptionsDialog/MusicSlider.value = Global.get_music_volume()

func _on_OptionsDialog_popup_hide():
	# Save the sound and music volumes
	Global.save_game()

func _on_ToggleFullScreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
	fullscreen_text()

func fullscreen_text():
	if OS.window_fullscreen:
		$OptionsDialog/ToggleFullScreen.text = "ON"
	else:
		$OptionsDialog/ToggleFullScreen.text = "OFF"

func _on_CloseStoryDialog_pressed():
	$StoryIntro.hide()
	$Levels.popup()

func _on_StoryIntro_about_to_show():
	$StoryIntro/Timer.start(story_duration)
