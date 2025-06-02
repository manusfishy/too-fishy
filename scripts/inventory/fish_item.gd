extends PanelContainer

# Signals
signal fish_released(fish_data)

# Node references
@onready var fish_image = $MarginContainer/VBoxContainer/FishImageContainer/FishTexture
@onready var weight_label = $MarginContainer/VBoxContainer/InfoContainer/WeightLabel
@onready var value_label = $MarginContainer/VBoxContainer/InfoContainer/ValueLabel
@onready var release_button = $MarginContainer/VBoxContainer/InfoContainer/ReleaseButton
@onready var count_badge = $MarginContainer/VBoxContainer/FishImageContainer/CountBadge
@onready var count_label = $MarginContainer/VBoxContainer/FishImageContainer/CountBadge/CountLabel
@onready var fish_image_container = $MarginContainer/VBoxContainer/FishImageContainer

# Fish data
var fish_data_list = [] # List of InvItem instances with same properties
var fish_type: int = 0

func _ready():
	# Connect button signal
	release_button.pressed.connect(_on_release_button_pressed)
	
	# Style the container
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.15, 0.3, 0.45, 0.8)
	hover_style.set_border_width_all(2)
	hover_style.border_color = Color(0.4, 0.6, 0.8)
	hover_style.set_corner_radius_all(8)
	add_theme_stylebox_override("hover", hover_style)
	
	# Style the release button
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.4, 0.7, 0.9)
	button_style.set_border_width_all(1)
	button_style.border_color = Color(0.4, 0.6, 0.9)
	button_style.set_corner_radius_all(5)
	release_button.add_theme_stylebox_override("normal", button_style)
	release_button.add_theme_color_override("font_color", Color(1, 1, 1))
	
	var button_hover_style = StyleBoxFlat.new()
	button_hover_style.bg_color = Color(0.3, 0.5, 0.8, 0.9)
	button_hover_style.set_border_width_all(1)
	button_hover_style.border_color = Color(0.5, 0.7, 1.0)
	button_hover_style.set_corner_radius_all(5)
	release_button.add_theme_stylebox_override("hover", button_hover_style)
	
	# Style the count badge
	var badge_style = StyleBoxFlat.new()
	badge_style.bg_color = Color(0.15, 0.3, 0.5, 0.9)
	badge_style.set_border_width_all(1)
	badge_style.border_color = Color(0.3, 0.5, 0.7)
	badge_style.set_corner_radius_all(12)
	count_badge.add_theme_stylebox_override("panel", badge_style)
	
	# Add additional slot styling
	var slot_style = StyleBoxFlat.new()
	slot_style.bg_color = Color(0.05, 0.15, 0.25, 0.8)
	slot_style.set_border_width_all(2)
	slot_style.border_color = Color(0.3, 0.5, 0.7, 0.5)
	slot_style.set_corner_radius_all(6)
	
	# Add subtle grid pattern to the slot
	slot_style.shadow_color = Color(0.2, 0.4, 0.6, 0.15)
	slot_style.shadow_size = 1
	slot_style.shadow_offset = Vector2(1, 1)
	
	fish_image_container.add_theme_stylebox_override("panel", slot_style)

func setup(items: Array):
	fish_data_list = items
	
	# Use the first item for display properties
	var item = items[0]
	
	# Set labels
	weight_label.text = "Weight: %.1f kg" % item.weight
	value_label.text = "Value: $%d" % item.price
	
	# Update count badge
	if items.size() > 1:
		count_badge.visible = true
		count_label.text = str(items.size())
	else:
		count_badge.visible = false
	
	# Find matching fish type based on price/weight ratio
	var price_per_weight = item.price / float(item.weight)
	fish_type = FishesConfig.FishType.FLAMY # Default type
	
	# Find the closest matching fish type based on price/weight ratio
	var best_match_diff = INF
	for type in FishesConfig.fishConfigMap:
		var config = FishesConfig.fishConfigMap[type]
		var avg_weight = (config.weight_min + config.weight_max) / 2.0
		var avg_price = avg_weight * config.price_weight_multiplier
		var config_ratio = avg_price / avg_weight
		
		var diff = abs(config_ratio - price_per_weight)
		if diff < best_match_diff:
			best_match_diff = diff
			fish_type = type
	
	# Load the fish image
	load_fish_image(item.shiny)

func load_fish_image(is_shiny: bool):
	# Get the fish config
	var fish_config = FishesConfig.fishConfigMap[fish_type]
	
	# TODO: Load prerendered fish image based on fish_type and is_shiny
	# Placeholder implementation - should be replaced with actual prerendered images
	var placeholder = ColorRect.new()
	placeholder.color = Color(0.2, 0.4, 0.7, 1.0)  # Placeholder blue color
	
	# Change color for shiny fish
	if is_shiny:
		placeholder.color = Color(0.8, 0.7, 0.2, 1.0)  # Golden color for shiny fish
	
	# Clear any existing content
	for child in fish_image.get_children():
		child.queue_free()
	
	fish_image.add_child(placeholder)
	placeholder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	placeholder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Add grid pattern overlay
	var grid_lines = Control.new()
	placeholder.add_child(grid_lines)
	grid_lines.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	grid_lines.connect("draw", _draw_grid_overlay.bind(grid_lines))
	
	# Add fish type label as placeholder
	var label = Label.new()
	label.text = "Fish Type: " + str(fish_type)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	placeholder.add_child(label)

func _draw_grid_overlay(control):
	var rect = control.get_rect()
	var line_color = Color(1, 1, 1, 0.1)
	
	# Draw horizontal lines
	for y in range(0, int(rect.size.y), 10):
		control.draw_line(Vector2(0, y), Vector2(rect.size.x, y), line_color, 1)
	
	# Draw vertical lines
	for x in range(0, int(rect.size.x), 10):
		control.draw_line(Vector2(x, 0), Vector2(x, rect.size.y), line_color, 1)

func add_fish(fish_item: InvItem) -> void:
	fish_data_list.append(fish_item)
	
	# Update count badge
	count_badge.visible = true
	count_label.text = str(fish_data_list.size())

func _on_release_button_pressed():
	# Release the last fish in the stack
	var fish_to_release = fish_data_list.pop_back()
	emit_signal("fish_released", fish_to_release)
	
	# Update UI if there are still fish in the stack
	if fish_data_list.size() > 0:
		if fish_data_list.size() > 1:
			count_label.text = str(fish_data_list.size())
		else:
			count_badge.visible = false
	
	# Queue for deletion if stack is empty
	if fish_data_list.size() == 0:
		queue_free() 
