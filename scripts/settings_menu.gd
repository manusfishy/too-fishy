extends Control

@onready var back_button = $Panel/MarginContainer/VBoxContainer/BackButton
@onready var status_label = $StatusLabel

# Audio settings
@onready var master_volume_slider = $Panel/MarginContainer/VBoxContainer/SettingsContainer/Audio/VBoxContainer/MasterVolumeSection/MasterVolumeSlider
@onready var music_volume_slider = $Panel/MarginContainer/VBoxContainer/SettingsContainer/Audio/VBoxContainer/MusicVolumeSection/MusicVolumeSlider
@onready var sfx_volume_slider = $Panel/MarginContainer/VBoxContainer/SettingsContainer/Audio/VBoxContainer/SFXVolumeSection/SFXVolumeSlider
@onready var mute_toggle = $Panel/MarginContainer/VBoxContainer/SettingsContainer/Audio/VBoxContainer/MuteToggleSection/MuteToggle

# Display settings
@onready var particles_toggle = $Panel/MarginContainer/VBoxContainer/SettingsContainer/Display/VBoxContainer/ParticlesSection/ParticlesToggle
@onready var fps_toggle = $Panel/MarginContainer/VBoxContainer/SettingsContainer/Display/VBoxContainer/FPSSection/FPSToggle

func _ready():
	# Style buttons
	_style_buttons()
	
	# Connect signals
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Update UI with current settings
	update_ui_from_settings()

func _style_buttons():
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.1, 0.25, 0.4, 0.9)
	button_style.set_border_width_all(2)
	button_style.border_color = Color(0.3, 0.5, 0.7)
	button_style.set_corner_radius_all(8)
	back_button.add_theme_stylebox_override("normal", button_style)
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.15, 0.3, 0.45, 0.9)
	hover_style.set_border_width_all(2)
	hover_style.border_color = Color(0.4, 0.6, 0.8)
	hover_style.set_corner_radius_all(8)
	back_button.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color(0.05, 0.2, 0.35, 0.9)
	pressed_style.set_border_width_all(2)
	pressed_style.border_color = Color(0.2, 0.4, 0.6)
	pressed_style.set_corner_radius_all(8)
	back_button.add_theme_stylebox_override("pressed", pressed_style)

func update_ui_from_settings():
	# Set UI elements from SettingsManager values
	master_volume_slider.value = SettingsManager.master_volume
	music_volume_slider.value = SettingsManager.music_volume
	sfx_volume_slider.value = SettingsManager.sfx_volume
	mute_toggle.button_pressed = SettingsManager.is_muted
	particles_toggle.button_pressed = SettingsManager.show_particles
	fps_toggle.button_pressed = SettingsManager.show_fps

func _on_master_volume_changed(value):
	SettingsManager.set_master_volume(value)
	show_status("Settings saved!")

func _on_music_volume_changed(value):
	SettingsManager.set_music_volume(value)
	show_status("Settings saved!")

func _on_sfx_volume_changed(value):
	SettingsManager.set_sfx_volume(value)
	show_status("Settings saved!")

func _on_mute_toggled(button_pressed):
	SettingsManager.set_mute(button_pressed)
	show_status("Settings saved!")

func _on_particles_toggled(button_pressed):
	SettingsManager.set_show_particles(button_pressed)
	show_status("Settings saved!")

func _on_fps_toggled(button_pressed):
	SettingsManager.set_show_fps(button_pressed)
	show_status("Settings saved!")

func _on_back_button_pressed():
	# Hide the settings menu and show pause menu elements
	get_parent().show_pause_elements(true)
	hide()

func show_status(message: String, duration: float = 2.0):
	status_label.text = message
	status_label.show()
	
	# Hide the status message after duration seconds
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(func(): status_label.hide()) 