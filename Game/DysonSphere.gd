extends "res://Game/CelestialBody.gd"

export (Vector2) var impulse0: Vector2 = Vector2(0, 0)
export (Resource) var texture
export (bool) var friendly: bool = false

const NeutralMoonScene = preload("res://Game/NeutralMoon.tscn")
const NeutralMoon = preload("res://Game/NeutralMoon.gd")
const DysonTexture = preload("res://Sprites/dyson.png")

var broken = false


func _ready():
	.apply_impulse(Vector2(0, 0), impulse0)
	for B in $Blocks.get_children():
		B.mode = RigidBody2D.MODE_STATIC
		B.inertia = 0
		B.collision_mask = 0
		B.collision_layer = 0
	var blocks = 9
	for i in range(0, blocks):
		var moon = NeutralMoonScene.instance()
		var rad = i * (2 * PI / blocks)
		var offset = 50
		var pos = Vector2(offset * sin(rad), offset * cos(rad))
		moon.position = pos
		moon.mode = RigidBody2D.MODE_STATIC
		moon.collision_layer = 0
		moon.collision_mask = 0
		moon.texture = DysonTexture
		moon.mass = 0.5
		$Blocks.add_child(moon)


# warning-ignore:unused_argument
func _process(delta):
	for B in $Blocks.get_children():
		B.update_shadow()


func check_asteroids(bh):
	for B in $Blocks.get_children():
		B.check_asteroids(bh)


func _on_DysonSphere_body_entered(body):
	for B in $Blocks.get_children():
		remove_child(B)
		var bodies = get_parent()
		var level = bodies.get_parent()
		var moon = NeutralMoonScene.instance()
		moon.texture = DysonTexture
		moon.position = B.position + position
		moon.mass = B.mass
		var av = B.position.rotated(90)
		moon.impulse0 = linear_velocity + B.position * Global.rng.randf_range(1, 15) + av * 10
		moon.connect("damage", level, "shake_it")
		moon.connect("friendly_destroyed", level, "friendly_destroyed")
		moon.explode_on_contact = true
		bodies.add_child(moon)
	queue_free()
