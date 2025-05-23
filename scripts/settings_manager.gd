extends Node

# Audio settings
var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var is_muted: bool = false

# Display settings
var show_particles: bool = true # Controls environmental particles (Bubbles, Debris) - not fish shiny effects or mining particles
var show_fps: bool = true

# Settings file
var config = ConfigFile.new()
var save_path = "user://settings.cfg"

func _ready():
	# Set global tooltip delay to 0 (show immediately)
	ProjectSettings.set_setting("gui/timers/tooltip_delay_sec", 0)
	
	# Load saved settings
	load_settings()
	
	# Apply loaded settings
	apply_audio_settings()
	apply_display_settings()

func load_settings():
	var err = config.load(save_path)
	
	if err != OK:
		# If the file doesn't exist or can't be loaded, use defaults and save them
		save_settings()
		return
	
	# Load audio settings
	master_volume = config.get_value("audio", "master_volume", 1.0)
	music_volume = config.get_value("audio", "music_volume", 1.0)
	sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
	is_muted = config.get_value("audio", "mute", false)
	
	# Load display settings with web-specific defaults for environmental particles
	var default_particles = true
	if OS.get_name() == "Web":
		default_particles = false # Disable environmental particles by default on web for performance
	
	show_particles = config.get_value("display", "particles", default_particles)
	show_fps = config.get_value("display", "fps_counter", true)
	
	# Apply settings
	apply_settings()

func save_settings():
	# Save audio settings
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "mute", is_muted)
	
	# Save display settings
	config.set_value("display", "particles", show_particles)
	config.set_value("display", "fps_counter", show_fps)
	
	config.save(save_path)

func apply_settings():
	# Apply audio settings
	apply_audio_settings()
	
	# Apply display settings
	apply_display_settings()

func apply_audio_settings():
	# Audio buses setup may vary depending on your project's configuration
	# This is a common approach:
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx >= 0:
		AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(master_volume))
		AudioServer.set_bus_mute(master_bus_idx, is_muted)
	
	var music_bus_idx = AudioServer.get_bus_index("Music")
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(music_volume))
	
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(sfx_volume))

func apply_display_settings():
	# We'll apply these when specific nodes become available
	# Find and handle particles
	var hud = get_node_or_null("/root/Node3D/UI/HUD")
	if hud:
		var particles_button = hud.get_node_or_null("MarginContainer/HUDContainer/MuteButton2")
		if particles_button:
			particles_button.button_pressed = show_particles
	
	# Handle FPS counter
	var fps_counter = get_node_or_null("/root/Node3D/UI/FPS Counter")
	if fps_counter:
		fps_counter.visible = show_fps

func set_master_volume(volume: float):
	master_volume = volume
	apply_audio_settings()
	save_settings()

func set_music_volume(volume: float):
	music_volume = volume
	apply_audio_settings()
	save_settings()

func set_sfx_volume(volume: float):
	sfx_volume = volume
	apply_audio_settings()
	save_settings()

func set_mute(muted: bool):
	is_muted = muted
	apply_audio_settings()
	save_settings()

# Helper function to check if environmental particles should be disabled
func should_disable_environmental_particles() -> bool:
	return not show_particles or OS.get_name() == "Web"

func set_show_particles(show: bool):
	show_particles = show
	apply_display_settings()
	
	# Apply to all existing sections
	var sections = get_tree().get_nodes_in_group("sections")
	for section in sections:
		if section.has_method("disableParticles"):
			if should_disable_environmental_particles():
				section.disableParticles()
			else:
				# Re-enable particles if setting is turned on and not on web
				if section.has_node("Bubbles"):
					section.get_node("Bubbles").visible = true
					section.get_node("Bubbles").emitting = true
				if section.has_node("Debris"):
					section.get_node("Debris").visible = true
					section.get_node("Debris").emitting = true
	
	save_settings()

func set_show_fps(show: bool):
	show_fps = show
	apply_display_settings()
	save_settings()

func toggle_mute():
	is_muted = !is_muted
	apply_audio_settings()
	save_settings()
	return is_muted