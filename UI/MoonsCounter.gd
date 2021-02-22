extends Control

var moons = 10 setget _set_moons, _get_moons
var game_over = false
var moons_width = [0, 32, 56, 80, 104, 128, 152, 176, 200, 224, 256]
var alternate_color = true

func _ready():
	$Foreground.region_enabled = true
	$Foreground.region_rect = Rect2(0, 0, 256, 32)

func _process(delta):
	$Particles.position = Vector2(moons_width[moons] + 12, 16)
	$Foreground.region_rect = Rect2(0, 0, moons_width[moons], 32)

func _set_moons(val):
	if moons > 0 :
		$Particles.restart()
	moons = clamp(val, 0, 10)
	if moons < 1:
		$Background.visible = false
		$Foreground.visible = false
		$FinalWarning.visible = true

func _get_moons():
	return moons

func _on_Timer_timeout():
	alternate_color = !alternate_color
	if alternate_color:
		$FinalWarning.set("custom_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
		if moons < 1 and !(game_over):
			$Alert.play()
			$Alert.set_volume_db(Global.get_sound_volume_db())
	else:
		$FinalWarning.set("custom_colors/font_color", Color(1.0, 1.0, 1.0, 1.0))
