extends PanelContainer

func _ready():
	# Create and set up custom styles for the pressure bar
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0, 0.36, 0.83)  # Default blue
	fill_style.corner_radius_top_left = 5
	fill_style.corner_radius_top_right = 5
	fill_style.corner_radius_bottom_right = 5
	fill_style.corner_radius_bottom_left = 5
	
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)  # Dark background
	bg_style.corner_radius_top_left = 5
	bg_style.corner_radius_top_right = 5
	bg_style.corner_radius_bottom_right = 5
	bg_style.corner_radius_bottom_left = 5
	
	# Apply the styles to the progress bar
	$MarginContainer/HUDContainer/PressureHeadroomBar.add_theme_stylebox_override("fill", fill_style)
	$MarginContainer/HUDContainer/PressureHeadroomBar.add_theme_stylebox_override("background", bg_style)

func _process(_delta: float) -> void:
	$MarginContainer/HUDContainer/DepthLabel.text = "Depth: %sm" % GameState.depth
	$MarginContainer/HUDContainer/MaxDepthLabel.text = "Depth Reached: %sm" % GameState.maxDepthReached
	# Money display moved to inventory UI
	$MarginContainer/HUDContainer/CurrentStageLabel.text = "%s" % Strings.stageNames[GameState.playerInStage]
	$MarginContainer/HUDContainer/HealthBar.value = GameState.health
	
	# Update pressure headroom bar value
	var headroom_value = GameState.headroom / (GameState.upgrades[GameState.Upgrade.DEPTH_RESISTANCE] + 1)
	$MarginContainer/HUDContainer/PressureHeadroomBar.value = headroom_value
	
	# Get the fill style
	var fill_style = $MarginContainer/HUDContainer/PressureHeadroomBar.get_theme_stylebox("fill")
	
	# Change bar color based on headroom percentage
	if headroom_value <= 0.15:  # 15% or less - red
		fill_style.bg_color = Color(1, 0, 0)  # Red
	elif headroom_value <= 0.3:  # Between 15% and 30% - orange
		fill_style.bg_color = Color(1, 0.5, 0)  # Orange
	else:  # Above 30% - default blue
		fill_style.bg_color = Color(0, 0.36, 0.83)  # Default blue
