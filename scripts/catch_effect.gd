extends Node3D

var is_shiny = false

func _ready():
	# Start the effect animation
	$Bubbles.emitting = true
	
	# Add a splash sound effect
	var audio_player = AudioStreamPlayer3D.new()
	add_child(audio_player)
	audio_player.max_distance = 10.0
	audio_player.unit_size = 4.0
	
	# Load sound effect based on if it's a shiny fish
	if is_shiny:
		audio_player.stream = load("res://sounds/harp3.wav")
		audio_player.pitch_scale = 0.8  # Deeper sound for shiny fish
		audio_player.volume_db = 2.0  # Louder for shiny fish
	else:
		audio_player.stream = load("res://sounds/bup.wav")
		audio_player.pitch_scale = randf_range(0.9, 1.1)  # Slight randomization
	
	audio_player.play()
	
	# Animate the flash and light
	var flash_tween = create_tween()
	flash_tween.set_parallel(true)
	flash_tween.tween_property($Flash, "scale", Vector3(2.0, 2.0, 2.0), 0.3)
	flash_tween.tween_property($Flash, "transparency", 1.0, 0.4)
	flash_tween.tween_property($OmniLight3D, "light_energy", 0, 0.5)
	
	# Scale down the flash effect
	var scale_tween = create_tween()
	scale_tween.tween_property($Flash, "scale", Vector3.ZERO, 0.5).set_delay(0.3)

func set_shiny(shiny_value):
	is_shiny = shiny_value
	if is_shiny:
		# Gold color for shiny fish
		$Bubbles.process_material.color = Color(1.0, 0.9, 0.2)
		$OmniLight3D.light_color = Color(1.0, 0.9, 0.2)
		$OmniLight3D.light_energy = 3.0  # Brighter light for shiny fish
	else:
		# Blue color for regular fish
		$Bubbles.process_material.color = Color(0.2, 0.7, 1.0)
		$OmniLight3D.light_color = Color(0.2, 0.7, 1.0)

func _on_timer_timeout():
	# Remove the effect after it completes
	queue_free() 