extends Node

var current_scene = null

var levels = [
	"res://Scenes/MainMenu.tscn",
	"res://Game/Level01.tscn",
	"res://Game/Level02.tscn",
	"res://Game/Level03.tscn",
	"res://Game/Level04.tscn",
	"res://Game/Level05.tscn",
	"res://Game/Level06.tscn",
	"res://Game/Level07.tscn",
	"res://Game/Level08.tscn",
	];

# Score for each level
# 0-3 means played with zero to three stars
# 5 means played but never completed
# 6 means never played and ready to play
# 7 means never played and disabled
var level_status = [
	6,
	7,
	7,
	7,
	7,
	7,
	7,
	7,
]

var music

func _ready():
	load_game()
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
	music = AudioStreamPlayer.new()
	var stream = load("res://Sounds/moonarchists.ogg")
	music.set_stream(stream)
	music.volume_db = 1
	music.pitch_scale = 1
	play_music()

func _process(delta):
	play_music()
	pass

func save_game() :
	var save_file = File.new()
	save_file.open("user://savegame.save", File.WRITE)
	for E in level_status:
		save_file.store_8(E);
	save_file.close()
	pass

func load_game() :
	var load_file = File.new()
	load_file.open("user://savegame.save", File.READ)
	for n in range(level_status.size()) :
		level_status[n] = load_file.get_8()
	pass

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()
	save_game()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)

func play_music() :
	if get_tree().get_root() != music.get_parent() :
		get_tree().get_root().add_child(music)
	if !music.playing:
		music.play()
