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
var base_volume = -15.0

# Debug variables to track section changes
var last_section_type = -1
var debug_timer = 0.0

func _ready():
	print("Music player initialized")
	
	# Get the mute button
	mute_button = get_node_or_null("/root/Node3D/UI/HUD/MarginContainer/HUDContainer/MuteButton")
	
	# Configure players to use the Music bus
	player1.bus = "Music"
	player2.bus = "Music"
	
	# Set up initial music
	_configure_players()
	
	# Connect to the player's section_changed signal
	_connect_to_player()
	
	# Update UI to match current state
	if mute_button:
		mute_button.text = "Unmute" if is_muted else "Mute"
	
	# Start playing immediately if not muted
	if !is_muted:
		player1.play()
		print("Started playing initial music: ", _get_track_name(current_track))

func _configure_players():
	# Set up player1 with surface music initially
	player1.stream = surface
	player1.volume_db = base_volume
	player1.stream.loop = true # Ensure looping is enabled
	
	# Set up player2 (silent initially)
	player2.stream = deep
	player2.volume_db = -80.0 # Silent
	player2.stream.loop = true # Ensure looping is enabled
	
	current_track = surface
	print("Players configured. Current music track: ", _get_track_name(current_track))

func _connect_to_player():
	var player_node = get_node_or_null("/root/Node3D/CharacterBody3D")
	if player_node:
		# Disconnect first in case this is called multiple times
		if player_node.section_changed.is_connected(_on_character_body_3d_section_changed):
			player_node.section_changed.disconnect(_on_character_body_3d_section_changed)
			
		# Connect to the signal
		player_node.section_changed.connect(_on_character_body_3d_section_changed)
	else:
		print("ERROR: Music player could not find player node at /root/Node3D/CharacterBody3D")

func _physics_process(delta):
	# Process crossfading in _physics_process for more consistent audio timing
	if is_crossfading:
		_process_crossfade(delta)
		
	# Ensure music is always playing
	_ensure_music_playing()

func _process(delta):
	# For debugging section changes
	debug_timer += delta
	if debug_timer >= 2.0:
		debug_timer = 0.0
		if GameState.playerInStage != last_section_type:
			last_section_type = GameState.playerInStage
			_check_section_based_music()
	
	# Periodically check if we should change the music based on section
	_check_section_based_music()

func _process_crossfade(delta):
	fade_timer += delta
	var t = min(fade_timer / fade_duration, 1.0) # Clamp t to [0,1]
	
	# Calculate volumes using linear interpolation in decibels
	var out_vol = lerp(base_volume, -80.0, t)
	var in_vol = lerp(-80.0, base_volume, t)
	
	# Apply volumes
	player1.volume_db = out_vol
	player2.volume_db = in_vol
	
	# Print debug info during fade
	#if fade_timer >= 0.5 and fade_timer < 0.51:
		# print("Fading - halfway point. Player1 vol: ", player1.volume_db, ", Player2 vol: ", player2.volume_db)
	if fade_timer >= fade_duration:
		# Crossfade is complete
		is_crossfading = false
		
		# Ensure final volumes are exact
		player1.volume_db = -80.0
		player2.volume_db = base_volume
		
		# Stop the first player now that it's silent
		player1.stop()
		
		#print("Crossfade complete. Stopping player1, final volumes - Player1: ", player1.volume_db, ", Player2: ", player2.volume_db)
		
		# Swap players for next crossfade
		var temp = player1
		player1 = player2
		player2 = temp
		
		current_track = next_track
	#	print("Now playing: ", _get_track_name(current_track))

func _ensure_music_playing():
	# If not muted and player1 isn't playing and we're not in the middle of a crossfade
	if !is_muted and !player1.playing and !is_crossfading:
		print("Music stopped unexpectedly, restarting")
		player1.play()

func _check_section_based_music():
	if GameState.playerInStage == null:
		return
		
	var expected_track = _get_track_for_section(GameState.playerInStage)
	
	# If we don't have the right track playing, and we're not already transitioning
	if expected_track != current_track and !is_crossfading:
		print("Section music mismatch. Current: ", _get_track_name(current_track),
			  " Expected: ", _get_track_name(expected_track))
		start_crossfade(expected_track)

func _get_track_for_section(section_type):
	match section_type:
		GameState.Stage.SURFACE:
			return surface
		GameState.Stage.DEEP, GameState.Stage.DEEPER, GameState.Stage.SUPERDEEP:
			return deep
		GameState.Stage.HOT, GameState.Stage.LAVA:
			return hotzone
		GameState.Stage.VOID:
			return bossfight
		_:
			return surface # Default to surface music

func _get_track_name(track):
	if track == surface:
		return "surface"
	elif track == deep:
		return "deep"
	elif track == hotzone:
		return "hotzone"
	elif track == bossfight:
		return "bossfight"
	else:
		return "unknown"

func start_crossfade(new_track):
	if new_track == current_track or is_muted:
		return # Don't crossfade if it's the same track or if muted
	
	#print("Starting crossfade from ", _get_track_name(current_track), " to ", _get_track_name(new_track))
	
	# Prepare player2 for the next track
	next_track = new_track
	player2.stream = next_track
	player2.stream.loop = true # Ensure looping is enabled
	
	# Start at silent volume
	player2.volume_db = -80.0
	
	# Start playing the new track (it will be silent initially)
	player2.play()
	
	# Reset fade timer and start crossfading
	fade_timer = 0.0
	is_crossfading = true
	
	#print("Crossfade started. Initial volumes - Player1: ", player1.volume_db, ", Player2: ", player2.volume_db)

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
	
	start_crossfade(sound_to_play)

func _on_mute_button_pressed():
	if !is_muted:
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
		player1.volume_db = pre_mute_volume1
		player2.volume_db = pre_mute_volume2
		
		# Make sure music is playing when unmuted
		if !player1.playing and !is_crossfading:
			player1.play()
			
		if mute_button:
			mute_button.text = "Mute"
		SettingsManager.set_mute(false)
	is_muted = !is_muted # Toggle mute state

func _on_character_body_3d_section_changed(sectionType):
	#print("Signal received: Section changed to ", sectionType)
	var track_to_play = _get_track_for_section(sectionType)
	start_crossfade(track_to_play)
