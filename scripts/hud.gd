extends PanelContainer

@onready var container = $MarginContainer/HUDContainer
@onready var depth_label = $MarginContainer/HUDContainer/DepthInfo/VBoxContainer/DepthValue
@onready var max_depth_label = $MarginContainer/HUDContainer/MaxDepthInfo/VBoxContainer/MaxDepthValue
@onready var current_stage_label = $MarginContainer/HUDContainer/StageInfo/VBoxContainer/StageValue
@onready var health_bar = $MarginContainer/HUDContainer/HealthInfo/HealthBar
@onready var pressure_headroom_bar = $MarginContainer/HUDContainer/PressureInfo/PressureBar
var _fill_style_override: StyleBoxFlat
var _health_fill_override: StyleBoxFlat

func _ready():
	# Create style overrides for pressure bar
	if is_instance_valid(pressure_headroom_bar):
		_fill_style_override = StyleBoxFlat.new()
		_fill_style_override.corner_radius_top_left = 4
		_fill_style_override.corner_radius_top_right = 4
		_fill_style_override.corner_radius_bottom_right = 4
		_fill_style_override.corner_radius_bottom_left = 4
		pressure_headroom_bar.add_theme_stylebox_override("fill", _fill_style_override)
   
	# Create style override for health bar
	if is_instance_valid(health_bar):
		_health_fill_override = StyleBoxFlat.new()
		_health_fill_override.bg_color = Color(0, 0.36, 0.83, 0.8)
		_health_fill_override.corner_radius_top_left = 4
		_health_fill_override.corner_radius_top_right = 4
		_health_fill_override.corner_radius_bottom_right = 4
		_health_fill_override.corner_radius_bottom_left = 4
		health_bar.add_theme_stylebox_override("fill", _health_fill_override)

	# Apply margins - keep these constant
	$MarginContainer.add_theme_constant_override("margin_left", 15)
	$MarginContainer.add_theme_constant_override("margin_right", 15)
	$MarginContainer.add_theme_constant_override("margin_top", 15)
	$MarginContainer.add_theme_constant_override("margin_bottom", 15)

func _process(_delta: float) -> void:
	depth_label.text = "%sm" % GameState.depth
	max_depth_label.text = "%sm" % GameState.maxDepthReached
	current_stage_label.text = "%s" % Strings.stageNames[GameState.playerInStage]
	
	# Update health bar value
	health_bar.value = GameState.health
	
	# Change health bar color based on health percentage
	if is_instance_valid(health_bar) and _health_fill_override:
		if GameState.health <= 15: # 15% or less - red
			_health_fill_override.bg_color = Color(0.918, 0.212, 0.212, 0.82) # Red
		elif GameState.health <= 30: # Between 15% and 30% - orange
			_health_fill_override.bg_color = Color(0.918, 0.525, 0.212, 0.82) # Orange
		else: # Above 30% - default blue
			_health_fill_override.bg_color = Color(0, 0.36, 0.83, 0.8) # Default blue
	
	# Update pressure headroom bar value
	var headroom_value = GameState.headroom / (GameState.upgrades[GameState.Upgrade.DEPTH_RESISTANCE] + 1)
	pressure_headroom_bar.value = headroom_value
	
	# Change pressure bar color based on headroom percentage
	if not is_instance_valid(pressure_headroom_bar) or not _fill_style_override:
		push_warning("ProgressBar or its fill_style_box_override is not properly initialized.")
		return
		
	if headroom_value <= 15: # 15% or less - red
		_fill_style_override.bg_color = Color(0.918, 0.212, 0.212, 0.82) # Red
	elif headroom_value <= 30: # Between 15% and 30% - orange
		_fill_style_override.bg_color = Color(0.918, 0.525, 0.212, 0.82) # Orange
	else: # Above 30% - default blue
		_fill_style_override.bg_color = Color(0, 0.36, 0.83, 0.8) # Default blue
