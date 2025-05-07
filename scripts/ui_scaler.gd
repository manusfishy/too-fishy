extends Node

# Reference resolution (optimized for 1920x1080)
const REFERENCE_WIDTH = 1920
const REFERENCE_HEIGHT = 1080

# Scaling factors
var scale_factor = 1.0
var font_scale_factor = 1.0

# Base font sizes for different UI elements
var base_font_sizes = {
	"normal": 16,
	"title": 24,
	"small": 14
}

func _ready():
	# Connect to window resize signal
	get_tree().root.size_changed.connect(_on_window_resize)
	
	# Initialize scaling
	_calculate_scale_factors()
	_apply_scaling()

func _on_window_resize():
	_calculate_scale_factors()
	_apply_scaling()

func _calculate_scale_factors():
	var window_size = DisplayServer.window_get_size()
	var window_width = window_size.x
	var window_height = window_size.y
	
	# Calculate scale factor based on the smaller ratio to ensure UI fits on screen
	var width_ratio = window_width / float(REFERENCE_WIDTH)
	var height_ratio = window_height / float(REFERENCE_HEIGHT)
	
	# Use the smaller ratio to ensure UI fits within the screen
	scale_factor = min(width_ratio, height_ratio)
	
	# Adjust font scaling - fonts typically need a less aggressive scaling
	# to remain readable on smaller screens
	font_scale_factor = lerp(0.8, 1.0, scale_factor)
	if scale_factor > 1.0:
		font_scale_factor = lerp(1.0, 1.2, (scale_factor - 1.0) / 0.5)
	
	print("Window size: ", window_size)
	print("Scale factor: ", scale_factor)
	print("Font scale factor: ", font_scale_factor)

func _apply_scaling():
	# Apply scaling to UI controls
	_scale_ui_elements(get_tree().root)
	
	# You may want to adjust camera properties for 3D viewport scaling here if needed

func _scale_ui_elements(node):
	# Recursively apply scaling to all UI elements
	if node is Control:
		# For containers that should maintain their relative size
		if node is MarginContainer:
			var current_margins = {
				"left": node.get("theme_override_constants/margin_left") if node.get("theme_override_constants/margin_left") != null else 0,
				"right": node.get("theme_override_constants/margin_right") if node.get("theme_override_constants/margin_right") != null else 0,
				"top": node.get("theme_override_constants/margin_top") if node.get("theme_override_constants/margin_top") != null else 0,
				"bottom": node.get("theme_override_constants/margin_bottom") if node.get("theme_override_constants/margin_bottom") != null else 0
			}
			
			node.add_theme_constant_override("margin_left", int(current_margins["left"] * scale_factor))
			node.add_theme_constant_override("margin_right", int(current_margins["right"] * scale_factor))
			node.add_theme_constant_override("margin_top", int(current_margins["top"] * scale_factor))
			node.add_theme_constant_override("margin_bottom", int(current_margins["bottom"] * scale_factor))
		
		# Scale custom minimum size
		if node.custom_minimum_size != Vector2.ZERO:
			node.custom_minimum_size = node.custom_minimum_size * scale_factor
		
		# Scale fonts
		_scale_fonts(node)
		
		# Scale textures for TextureRect
		if node is TextureRect and node.texture != null:
			var texture_size = node.texture.get_size()
			node.custom_minimum_size = texture_size * scale_factor
	
	# Recursively process children
	for child in node.get_children():
		_scale_ui_elements(child)

func _scale_fonts(control):
	# Apply font scaling to various Controls that display text
	if control is Label or control is Button or control is LineEdit or control is TextEdit:
		var font_size = control.get("theme_override_font_sizes/font_size")
		if font_size != null:
			control.add_theme_font_size_override("font_size", int(font_size * font_scale_factor))
		else:
			# Assign default font size based on control type if none exists
			var base_size = base_font_sizes["normal"]
			if control is Label and control.get_parent() is PanelContainer and control.get_parent().get_child_count() == 1:
				# This might be a title label
				base_size = base_font_sizes["title"]
			elif control is Button:
				base_size = base_font_sizes["normal"]
			
			control.add_theme_font_size_override("font_size", int(base_size * font_scale_factor)) 
