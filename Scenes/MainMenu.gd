extends Control

var click_start;

func _ready():
	$Play.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass

func _process(delta):
	pass

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()

func _on_exit_pressed():
	get_tree().quit()
	pass

func _on_play_pressed():
	$Levels.popup()
	pass

func _on_Options_pressed():
	$OptionsDialog.popup()
	pass

func _on_CloseCreditsDialog_pressed():
	$CreditsDialog.hide()
	pass

func _on_Credits_pressed():
	$CreditsDialog.popup()
	pass

func _on_CloseOptionsDialog_pressed():
	$OptionsDialog.hide()
	pass

func _on_CloseLevelsDialog_pressed():
	$Levels.hide()
	pass

func _on_SoundSlider_value_changed(value):
	Global.set_sound_volume(value)
	pass

func _on_MusicSlider_value_changed(value):
	Global.set_music_volume(value)
	pass

func _on_OptionsDialog_about_to_show():
	$OptionsDialog/SoundSlider.value = Global.get_sound_volume()
	$OptionsDialog/MusicSlider.value = Global.get_music_volume()
	pass

func _on_OptionsDialog_popup_hide():
	# Save the sound and music volumes
	Global.save_game()
	pass
