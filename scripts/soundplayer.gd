extends Node3D

# Preload the sound files
var bupp = preload("res://sounds/bupp.wav")
var urrgh = preload("res://sounds/urrgh.wav")
var ughhh = preload("res://sounds/ughhh.wav")
var ouugh = preload("res://sounds/Ouugh.wav")
var bup = preload("res://sounds/bup.wav")
var coins = preload("res://sounds/coins.wav")

var harp = preload("res://sounds/harp.wav")
var harp2 = preload("res://sounds/harp2.wav")
var harp3 = preload("res://sounds/harp3.wav")

@onready var player = $player


func play_sound(sound_name: String):
	var sound_to_play
	match sound_name:
		"bupp":
			sound_to_play = bupp
		"urrgh":
			sound_to_play = urrgh
		"ughhh":
			sound_to_play = ughhh
		"ouugh":
			sound_to_play = ouugh
		"bup":
			sound_to_play = bup
		"harp":
			sound_to_play = harp
		"harp2":
			sound_to_play = harp2
		"harp3":
			sound_to_play = harp3
		"coins":
			sound_to_play = coins
		_:
			print("Unknown sound: ", sound_name)
			return
	
	# Assign the sound and play it
	player.stream = sound_to_play
	player.play()
