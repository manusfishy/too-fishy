extends Node

# Audio settings
var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var is_muted: bool = false

# Display settings
var show_particles: bool = true
var show_fps: bool = true

# Settings file
var config = ConfigFile.new()
var save_path = "user://settings.cfg"

func _ready():
	load_settings()

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
	
	# Load display settings
	show_particles = config.get_value("display", "particles", true)
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

func set_show_particles(show: bool):
	show_particles = show
	apply_display_settings()
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