extends Button

export (int) var level_number : int = 1 setget set_level_number

const star_texture_full = preload("res://Sprites/star_full.png")
const star_texture_empty = preload("res://Sprites/star_empty.png")

func _ready():
	setup()

func set_level_number(ln):
	level_number = ln
	setup()

func setup():
	var level_name = String(level_number)
	if(level_number<10):
		level_name = "0" + level_name
	$Name.text = level_name
	var stars = Global.level_status[level_number-1]
	$Star1.set_texture(star_texture_empty)
	$Star2.set_texture(star_texture_empty)
	$Star3.set_texture(star_texture_empty)
	if stars < 4:
		if stars > 0 :
			$Star1.set_texture(star_texture_full)
		if stars > 1 :
			$Star2.set_texture(star_texture_full)
		if stars > 2 :
			$Star3.set_texture(star_texture_full)
	if stars < 7:
		$Name.set("custom_colors/font_color", Color(1.0, 1.0, 1.0, 1.0))
		$Lock.hide()
		$Star1.show()
		$Star2.show()
		$Star3.show()
	else:
		$Name.set("custom_colors/font_color", Color(0.3, 0.3, 0.3, 1.0))
		$Lock.show()
		$Star1.hide()
		$Star2.hide()
		$Star3.hide()

func _on_Level_pressed():
	beep()
	var stars = Global.level_status[level_number-1]
	if stars < 7:
		Global.current_level = level_number

func beep():
	$Beep.play()
	$Beep.set_volume_db(Global.get_sound_volume_db())
