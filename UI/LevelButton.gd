extends Button

export (int) var level_number : int = 1
export (String) var level_name : String = "01"

var star_texture = preload("res://Sprites/star_full.png")

func _ready():
	$Name.text = level_name
	var stars = Global.level_status[level_number-1]
	if stars < 4:
		if stars > 0 :
			$Star1.set_texture(star_texture)
		if stars > 1 :
			$Star2.set_texture(star_texture)
		if stars > 2 :
			$Star3.set_texture(star_texture)
	pass

func _on_Level_pressed():
	var stars = Global.level_status[level_number-1]
	if stars < 7:
		Global.goto_scene(Global.levels[level_number])
	pass
