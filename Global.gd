extends Node

const game_version = 19

var current_scene = null
var music_volume = 75
var sound_volume = 90
var music
var use_cross_hair = true setget _set_cross_hair, _get_cross_hair
var use_joy_pad = false
var speed_run_start_time
var speed_run_record = 0
var is_speedrunning = false
var slowmo
var rng = RandomNumberGenerator.new()

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
	"res://Game/Level09.tscn",
	"res://Game/Level02.tscn",
	"res://Game/Level03.tscn",
	"res://Game/Level04.tscn",
	"res://Game/Level05.tscn",
	"res://Game/Level06.tscn",
	"res://Game/Level07.tscn",
	"res://Game/Level08.tscn",
	"res://Game/Level01.tscn",
	"res://Game/Level02.tscn",
	"res://Game/Level03.tscn",
	"res://Game/Level04.tscn",
	"res://Game/Level05.tscn",
	"res://Game/Level06.tscn",
	"res://Game/Level07.tscn",
	"res://Game/Level08.tscn",
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
	6,	7,	7,	7,	7,	7,	7,	7,
	7,	7,	7,	7,	7,	7,	7,	7,
	7,	7,	7,	7,	7,	7,	7,	7,
	7,	7,	7,	7,	7,	7,	7,	7,
]

func start_speed_run():
	speed_run_start_time = OS.get_ticks_msec()
	is_speedrunning = true

func abort_speed_run():
	is_speedrunning = false

func stop_speed_run():
	is_speedrunning = false
	var speed_run_time = OS.get_ticks_msec() - speed_run_start_time
	if speed_run_record <= 0:
		speed_run_record = speed_run_time
	if speed_run_record > speed_run_time:
		speed_run_record = speed_run_time
	return speed_run_time

func get_partial_speed_run():
	return OS.get_ticks_msec() - speed_run_start_time

func ms2str(t):
	var seconds = int(t/1000)
	var millis = t-seconds*1000
	var minutes = int(floor(seconds/60))
	seconds = seconds - minutes*60
	return String(minutes) + ":" + String(seconds) + ":" + String(millis)

func _set_cross_hair(val):
	use_cross_hair = val

func _get_cross_hair():
	return use_cross_hair

func get_total_stars():
	var total_stars = 0
	for E in level_status:
		if E < 5:
			total_stars += E
	return total_stars

func _ready():
	end_slowmo()
	load_game()
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
	music = AudioStreamPlayer.new()
	var stream = load("res://Sounds/moonarchists.ogg")
	music.set_stream(stream)
	music.volume_db = 1
	music.pitch_scale = 1
	play_music()
	slowmo = Timer.new()
	slowmo.connect("timeout", self, "end_slowmo")
	add_child(slowmo)

func do_slowmo():
	slowmo.start(0.05)
	Engine.time_scale = 0.20
	Engine.iterations_per_second = 10

func end_slowmo():
	Engine.time_scale = 0.75
	Engine.iterations_per_second = 60

func _process(delta):
	play_music()

func save_game() :
	var save_file = File.new()
	save_file.open("user://savegame.save", File.WRITE)
	save_file.store_8(game_version)
	for E in level_status:
		save_file.store_8(E);
	save_file.store_8(sound_volume)
	save_file.store_8(music_volume)
	save_file.store_8(use_cross_hair)
	save_file.store_64(speed_run_record)
	save_file.close()

func load_game() :
	var load_file = File.new()
	if load_file.file_exists("user://savegame.save"):
		load_file.open("user://savegame.save", File.READ)
		var version = load_file.get_8()
		if version == game_version:
			for n in range(level_status.size()) :
				level_status[n] = load_file.get_8()
			sound_volume = load_file.get_8()
			music_volume = load_file.get_8()
			use_cross_hair = load_file.get_8()
			speed_run_record = load_file.get_64()
		load_file.close()

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
	current_scene.free()
	save_game()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)

func play_music() :
	if get_tree().get_root() != music.get_parent() :
		get_tree().get_root().add_child(music)
	if !music.playing:
		music.play()
	music.set_volume_db(-50 + music_volume/2)

func get_sound_volume_db():
	return (-50 + sound_volume/2)

func set_sound_volume(volume):
	sound_volume = volume

func set_music_volume(volume):
	music_volume = volume

func get_sound_volume():
	return sound_volume

func get_music_volume():
	return music_volume
