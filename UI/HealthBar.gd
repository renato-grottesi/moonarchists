extends Control

export (int) var health setget _set_health, _get_health

var initial_position
var animated_health = 100

func _ready():
	$Foreground.region_enabled = true
	$Foreground.region_rect = Rect2(0, 0, 256, 32)
	initial_position = $Foreground.position

func _process(delta):
	if animated_health > health:
		$Particles.emitting = true
		animated_health -= delta * 75
	else:
		$Particles.emitting = false
	var width = 2.56 * animated_health
	$Particles.position = Vector2(width, 8)
	$Foreground.region_rect = Rect2(0, 0, width, 32)
	$Foreground.position = initial_position - Vector2((256-width)/2, 0)

func _set_health(h):
	if animated_health < 0:
		health = 0
		animated_health = health
	health = h

func _get_health():
	return health
