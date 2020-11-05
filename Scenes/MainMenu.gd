extends Node2D

var click_start;

func _ready():
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
	Global.goto_scene("res://Game/Level01.tscn")
	pass
