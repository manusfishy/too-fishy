extends PanelContainer

func _ready() -> void:
	# Connect particle toggle button
	$MarginContainer/HUDContainer/ParticleToggleButton.pressed.connect(_on_particle_toggle_button_pressed)
	# Set initial button text based on current particle state
	update_particle_button_text()

func _process(_delta: float) -> void:
	$MarginContainer/HUDContainer/DepthLabel.text = "Depth: %sm" % GameState.depth
	$MarginContainer/HUDContainer/MaxDepthLabel.text = "Depth Reached: %sm" % GameState.maxDepthReached
	$MarginContainer/HUDContainer/MoneyLabel.text = "Money: %s" % GameState.money
	$MarginContainer/HUDContainer/CurrentStageLabel.text = "%s" % Strings.stageNames[GameState.playerInStage]
	$MarginContainer/HUDContainer/HealthBar.value = GameState.health
	$MarginContainer/HUDContainer/PressureHeadroomBar.value = GameState.headroom / (GameState.upgrades[GameState.Upgrade.DEPTH_RESISTANCE] + 1)

func _on_particle_toggle_button_pressed() -> void:
	# Toggle particles in GameState
	GameState.toggle_particles()
	# Update button text
	update_particle_button_text()

func update_particle_button_text() -> void:
	var button = $MarginContainer/HUDContainer/ParticleToggleButton
	if GameState.particles_enabled:
		button.text = "Particles: ON"
	else:
		button.text = "Particles: OFF"
