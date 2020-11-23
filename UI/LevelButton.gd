extends Button

export (int) var level_number : int = 1
export (String) var level_name : String = "01"

const star_texture = preload("res://Sprites/star_full.png")

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
	if stars < 7:
		$Name.set("custom_colors/font_color", Color(1.0, 1.0, 1.0, 1.0))
		$Lock.hide()
	else:
		$Name.set("custom_colors/font_color", Color(0.3, 0.3, 0.3, 1.0))
		$Star1.hide()
		$Star2.hide()
		$Star3.hide()

func _on_Level_pressed():
	var stars = Global.level_status[level_number-1]
	if stars < 7:
		Global.goto_scene(Global.levels[level_number])
