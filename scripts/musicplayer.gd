extends Node

@onready var player1 = $AudioStreamPlayer # First audio player
@onready var player2 = $AudioStreamPlayer2 # Second audio player
var fade_duration = 2.0 # Duration of the crossfade in seconds
var fade_timer = 0.0
var is_crossfading = false
var is_muted = false # Track mute state
var pre_mute_volume1 = -15.0
var pre_mute_volume2 = -15.0
var mute_button = null
var surface = preload("res://music/surface.mp3")
var deep = preload("res://music/deep.mp3")
var bossfight = preload("res://music/bossfight.mp3")
var hotzone = preload("res://music/hotzone.mp3")

var current_track = null
var next_track = null

func _ready():
	mute_button = get_node("/root/Node3D/UI/HUD/MarginContainer/HUDContainer/MuteButton")
	
	# Configure players to use the Music bus
	player1.bus = "Music"
	player2.bus = "Music"
	
	# Apply current settings
	is_muted = SettingsManager.is_muted
	
	# Start with surface music
	player1.stream = surface
	player1.stream.loop = true
	player2.stream = deep
	player2.stream.loop = true
	
	# Start playing the first track
	var base_volume = -15.0
	player1.volume_db = base_volume
	player2.volume_db = base_volume
	#player1.play()
	current_track = surface

func _process(delta):
	if is_crossfading:
		fade_timer += delta
		var t = fade_timer / fade_duration
		
		# Interpolate volumes (linear decibels)
		var base_volume = -15.0
		player1.volume_db = lerp(base_volume, -80.0, t) # Fade out
		player2.volume_db = lerp(-80.0, base_volume, t) # Fade in
		
		if fade_timer >= fade_duration:
			is_crossfading = false
			player1.stop() # Stop the first track when fully faded out
			# Swap players for next crossfade
			var temp = player1
			player1 = player2
			player2 = temp
			current_track = next_track

func start_crossfade(new_track):
	if new_track == current_track:
		return # Don't crossfade if it's the same track
		
	next_track = new_track
	player2.stream = next_track
	player2.play()
	fade_timer = 0.0
	is_crossfading = true

func play_sound(sound_name: String):
	var sound_to_play
	match sound_name:
		"bossfight":
			sound_to_play = bossfight
		"deep":
			sound_to_play = deep
		"hotzone":
			sound_to_play = hotzone
		"surface":
			sound_to_play = surface
		_:
			print("Unknown sound: ", sound_name)
			return
	
	# Assign the sound and play it
	player1.stream = sound_to_play
	player1.play()


func _on_mute_button_pressed():
	if !is_muted:
		player1.stop() # for now stop if unmute, without crossfade
		# Store current volumes and mute
		pre_mute_volume1 = player1.volume_db
		pre_mute_volume2 = player2.volume_db
		player1.volume_db = -80.0
		player2.volume_db = -80.0
		if mute_button:
			mute_button.text = "Unmute"
		SettingsManager.set_mute(true)
	else:
		# Restore previous volumes
		player1.play() # for now play if unmute, without crossfade
		player1.volume_db = -15 # pre_mute_volume1
		player2.volume_db = -15 # pre_mute_volume2
		if mute_button:
			mute_button.text = "Mute"
		SettingsManager.set_mute(false)
	is_muted = !is_muted # Toggle mute state

#	0: Stage.SURFACE,
#	100: Stage.DEEP,
#	200: Stage.DEEPER,
#	300: Stage.SUPERDEEP,
#	400: Stage.HOT,
#	500: Stage.LAVA,
#	600: Stage.VOID
# surface =
# deep 
# bossfight
# hotzone =
func _on_character_body_3d_section_changed(sectionType):
	var track_to_play
	match sectionType:
		GameState.Stage.SURFACE:
			track_to_play = surface
		GameState.Stage.DEEP, GameState.Stage.DEEPER, GameState.Stage.SUPERDEEP:
			track_to_play = deep
		GameState.Stage.HOT, GameState.Stage.LAVA:
			track_to_play = hotzone
		GameState.Stage.VOID:
			track_to_play = bossfight
	
	start_crossfade(track_to_play)
