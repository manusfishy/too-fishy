extends PanelContainer

@onready var container = $MarginContainer/HUDContainer
@onready var depth_label = $MarginContainer/HUDContainer/DepthInfo/VBoxContainer/DepthValue
@onready var max_depth_label = $MarginContainer/HUDContainer/MaxDepthInfo/VBoxContainer/MaxDepthValue
@onready var current_stage_label = $MarginContainer/HUDContainer/StageInfo/VBoxContainer/StageValue
@onready var health_bar = $MarginContainer/HUDContainer/HealthInfo/HealthBar
@onready var pressure_headroom_bar = $MarginContainer/HUDContainer/PressureInfo/PressureBar

# Cooldown progress bars
@onready var harpoon_cd_bar = $MarginContainer/HUDContainer/CooldownInfo/VBoxContainer/HarpoonCD
@onready var buoy_cd_bar = $MarginContainer/HUDContainer/CooldownInfo/VBoxContainer/BuoyCD
@onready var drone_cd_bar = $MarginContainer/HUDContainer/CooldownInfo/VBoxContainer/DroneCD
@onready var ak47_cd_bar = $MarginContainer/HUDContainer/CooldownInfo/VBoxContainer/AK47CD

var _fill_style_override: StyleBoxFlat
var _health_fill_override: StyleBoxFlat
var _harpoon_fill_override: StyleBoxFlat
var _buoy_fill_override: StyleBoxFlat
var _drone_fill_override: StyleBoxFlat
var _ak47_fill_override: StyleBoxFlat

const COLOR_COOLDOWN_READY = Color(0, 0.36, 0.83, 0.8) # Blue
const COLOR_COOLDOWN_ACTIVE = Color(0.918, 0.525, 0.212, 0.82) # Orange

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
		
	# Create style overrides for cooldown bars
	if is_instance_valid(harpoon_cd_bar):
		_harpoon_fill_override = create_cooldown_style()
		harpoon_cd_bar.add_theme_stylebox_override("fill", _harpoon_fill_override)
		
	if is_instance_valid(buoy_cd_bar):
		_buoy_fill_override = create_cooldown_style()
		buoy_cd_bar.add_theme_stylebox_override("fill", _buoy_fill_override)
		
	if is_instance_valid(drone_cd_bar):
		_drone_fill_override = create_cooldown_style()
		drone_cd_bar.add_theme_stylebox_override("fill", _drone_fill_override)
		
	if is_instance_valid(ak47_cd_bar):
		_ak47_fill_override = create_cooldown_style()
		ak47_cd_bar.add_theme_stylebox_override("fill", _ak47_fill_override)

	# Apply margins - keep these constant
	$MarginContainer.add_theme_constant_override("margin_left", 15)
	$MarginContainer.add_theme_constant_override("margin_right", 15)
	$MarginContainer.add_theme_constant_override("margin_top", 15)
	$MarginContainer.add_theme_constant_override("margin_bottom", 15)

func create_cooldown_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.bg_color = COLOR_COOLDOWN_READY
	return style

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

	if GameState.player_node:
		# Update cooldown bars
		if is_instance_valid(harpoon_cd_bar):
			var harpoon_timer = GameState.player_node.get_node("HarpoonCD")
			if harpoon_timer:
				var time_left = harpoon_timer.time_left
				harpoon_cd_bar.value = harpoon_timer.wait_time - time_left
				harpoon_cd_bar.visible = true # Always show harpoon cooldown
				_harpoon_fill_override.bg_color = COLOR_COOLDOWN_ACTIVE if time_left > 0 else COLOR_COOLDOWN_READY
		
		if is_instance_valid(buoy_cd_bar):
			var buoy_timer = GameState.player_node.get_node("BuoyCD")
			if buoy_timer:
				var time_left = buoy_timer.time_left
				buoy_cd_bar.value = buoy_timer.wait_time - time_left
				buoy_cd_bar.visible = GameState.upgrades[GameState.Upgrade.SURFACE_BUOY] > 0
				_buoy_fill_override.bg_color = COLOR_COOLDOWN_ACTIVE if time_left > 0 else COLOR_COOLDOWN_READY
		
		if is_instance_valid(drone_cd_bar):
			var drone_timer = GameState.player_node.get_node("DroneCD")
			if drone_timer:
				var time_left = drone_timer.time_left
				drone_cd_bar.value = drone_timer.wait_time - time_left
				drone_cd_bar.visible = GameState.upgrades[GameState.Upgrade.DRONE_SELLING] > 0
				_drone_fill_override.bg_color = COLOR_COOLDOWN_ACTIVE if time_left > 0 else COLOR_COOLDOWN_READY
				
		if is_instance_valid(ak47_cd_bar):
			var ak47 = GameState.player_node.get_node("Pivot/SmFishSubmarine/ak47_0406195124_texture")
			if ak47 and GameState.upgrades[GameState.Upgrade.AK47] > 0:
				ak47_cd_bar.visible = true
				var max_ammo = ak47.get_max_ammo()
				if ak47.is_currently_reloading():
					ak47_cd_bar.value = ak47.get_reload_progress()
					_ak47_fill_override.bg_color = COLOR_COOLDOWN_ACTIVE
					ak47_cd_bar.get_node("Label").text = "AK47 (%d/%d) - Reloading" % [ak47.get_current_ammo(), max_ammo]
				else:
					ak47_cd_bar.value = 1.0
					_ak47_fill_override.bg_color = COLOR_COOLDOWN_READY
					ak47_cd_bar.get_node("Label").text = "AK47 (%d/%d)" % [ak47.get_current_ammo(), max_ammo]
			else:
				ak47_cd_bar.visible = false
