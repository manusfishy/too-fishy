extends PanelContainer

@onready var container = $MarginContainer/HUDContainer
@onready var depth_label = $MarginContainer/HUDContainer/DepthLabel
@onready var max_depth_label = $MarginContainer/HUDContainer/MaxDepthLabel
@onready var current_stage_label = $MarginContainer/HUDContainer/CurrentStageLabel
@onready var health_bar = $MarginContainer/HUDContainer/HealthBar
@onready var pressure_headroom_bar = $MarginContainer/HUDContainer/PressureHeadroomBar

func _ready():
	# Set minimum width for the HUD to avoid it becoming too small
	custom_minimum_size.x = 250
	
	# Connect to window resize signal to handle UI adjustments
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	# Initial adjustment
	_on_viewport_size_changed()

func _on_viewport_size_changed():
	# Adjust HUD size based on window size
	var window_size = DisplayServer.window_get_size()
	
	# Scale HUD width based on screen width, but keep it reasonable
	var target_width = max(250, window_size.x * 0.2)
	custom_minimum_size.x = target_width
	
	# Also adjust the margin container padding
	var margin_size = int(max(10, target_width * 0.1))
	$MarginContainer.add_theme_constant_override("margin_left", margin_size)
	$MarginContainer.add_theme_constant_override("margin_right", margin_size)
	$MarginContainer.add_theme_constant_override("margin_top", margin_size)
	$MarginContainer.add_theme_constant_override("margin_bottom", margin_size)

func _process(_delta: float) -> void:
	depth_label.text = "Depth: %sm" % GameState.depth
	max_depth_label.text = "Depth Reached: %sm" % GameState.maxDepthReached
	# Money display moved to inventory UI
	current_stage_label.text = "%s" % Strings.stageNames[GameState.playerInStage]
	health_bar.value = GameState.health
	
	# Update pressure headroom bar value
	var headroom_value = GameState.headroom / (GameState.upgrades[GameState.Upgrade.DEPTH_RESISTANCE] + 1)
	pressure_headroom_bar.value = headroom_value
	
	# Change bar color based on headroom percentage
	if headroom_value <= 0.15:  # 15% or less - red
		# Change both the bar color and the modulate property for full effect
		var style_box = pressure_headroom_bar.get("theme_override_styles/fill")
		if style_box == null:
			style_box = StyleBoxFlat.new()
			pressure_headroom_bar.set("theme_override_styles/fill", style_box)
		style_box.bg_color = Color(1, 0, 0)  # Red
	elif headroom_value <= 0.3:  # Between 15% and 30% - orange
		var style_box = pressure_headroom_bar.get("theme_override_styles/fill")
		if style_box == null:
			style_box = StyleBoxFlat.new()
			pressure_headroom_bar.set("theme_override_styles/fill", style_box)
		style_box.bg_color = Color(1, 0.5, 0)  # Orange
	else:  # Above 30% - default blue
		var style_box = pressure_headroom_bar.get("theme_override_styles/fill")
		if style_box == null:
			style_box = StyleBoxFlat.new()
			pressure_headroom_bar.set("theme_override_styles/fill", style_box)
		style_box.bg_color = Color(0, 0.36, 0.83)  # Default blue
