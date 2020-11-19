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
