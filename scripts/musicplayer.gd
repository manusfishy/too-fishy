extends Node

@onready var player1 = $AudioStreamPlayer # First audio player
@onready var player2 = $AudioStreamPlayer2 # Second audio player
var fade_duration = 2.0 # Duration of the crossfade in seconds
var fade_timer = 0.0
var is_crossfading = false

var surface = preload("res://music/surface.mp3")
var deep = preload("res://music/deep.mp3")
var bossfight = preload("res://music/bossfight.mp3")
var hotzone = preload("res://music/hotzone.mp3")

func _ready():
	# Load the audio files
	# Preload the sound files
	player1.stream = surface
	player2.stream = deep
	
	# Start playing the first track
	player1.volume_db = 0.0 # Full volume
	player2.volume_db = -80.0 # Muted
	player1.play()
	
#	0: Stage.SURFACE,
#	100: Stage.DEEP,
#	200: Stage.DEEPER,
#	300: Stage.SUPERDEEP,
#	400: Stage.HOT,
#	500: Stage.LAVA,
#	600: Stage.VOID


func _process(delta):
	# Example trigger: Press "ui_accept" (e.g., Enter key) to start crossfade
	# Handle the crossfade
	if is_crossfading:
		fade_timer += delta
		var t = fade_timer / fade_duration
		
		# Interpolate volumes (linear decibels)
		player1.volume_db = lerp(0.0, -80.0, t) # Fade out
		player2.volume_db = lerp(-80.0, 0.0, t) # Fade in
		
		if fade_timer >= fade_duration:
			is_crossfading = false
			player1.stop() # Stop the first track when fully faded out

func start_crossfade():
	if not player2.playing:
		player2.play() # Start the second track
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


func _on_stage_changed(new_stage):
	# Trigger crossfade when the stage changes
	if new_stage == "Stage2": # Example condition
		start_crossfade()
