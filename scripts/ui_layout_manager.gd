extends Node

# Reference resolution dimensions
const REFERENCE_WIDTH = 1920
const REFERENCE_HEIGHT = 1080

# Breakpoints for different layouts
const SMALL_SCREEN_WIDTH = 800
const SMALL_SCREEN_HEIGHT = 600
const MEDIUM_SCREEN_WIDTH = 1280
const MEDIUM_SCREEN_HEIGHT = 720

# Aspect ratio thresholds
const WIDE_ASPECT_RATIO = 1.8 # For ultrawide monitors (e.g., 21:9)
const NARROW_ASPECT_RATIO = 1.5 # For tablets or vertical orientations

# Layout types
enum LayoutType {SMALL, MEDIUM, LARGE, WIDE, NARROW}

# Current layout type
var current_layout = LayoutType.LARGE

# UI container references
var ui_root: Control
var hud: Control
var inventory: Control
var dialog_container: Control
var upgrades_container: Control

# Track if initialized
var initialized = false

func _ready():
	# Wait two frames to ensure all UI elements are properly initialized
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Get UI references
	_find_ui_elements()
	
	# Connect window resize signal
	get_viewport().size_changed.connect(_on_window_size_changed)
	
	# Apply initial layout
	_update_layout()
	
	# Set global tooltip settings
	_set_global_tooltip_settings()
	
	initialized = true

func _find_ui_elements():
	# Find the UI root and all important containers
	var scene_root = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	
	# Find UI root
	ui_root = scene_root.find_child("UI", true, false)
	
	if ui_root:
		# Find key UI components
		hud = ui_root.find_child("HUD", true, false)
		inventory = ui_root.find_child("inv_ui", true, false)
		
		var center_container = ui_root.find_child("CenterContainer", true, false)
		if center_container:
			dialog_container = center_container.find_child("BossDialog", true, false)
			upgrades_container = center_container.find_child("Upgrades", true, false)

func _on_window_size_changed():
	if initialized:
		_update_layout()

func _update_layout():
	if !ui_root:
		return
		
	var window_size = DisplayServer.window_get_size()
	var width = window_size.x
	var height = window_size.y
	var aspect_ratio = float(width) / float(height)
	
	# Determine layout type based on screen dimensions and aspect ratio
	var new_layout
	
	if width <= SMALL_SCREEN_WIDTH || height <= SMALL_SCREEN_HEIGHT:
		new_layout = LayoutType.SMALL
	elif width <= MEDIUM_SCREEN_WIDTH || height <= MEDIUM_SCREEN_HEIGHT:
		new_layout = LayoutType.MEDIUM
	else:
		if aspect_ratio >= WIDE_ASPECT_RATIO:
			new_layout = LayoutType.WIDE
		elif aspect_ratio <= NARROW_ASPECT_RATIO:
			new_layout = LayoutType.NARROW
		else:
			new_layout = LayoutType.LARGE
	
	# Only update if layout changed
	if new_layout != current_layout:
		current_layout = new_layout
		_apply_layout(current_layout)

func _apply_layout(layout_type):
	print("Applying layout: ", layout_type)
	
	# Reset all UI positions first
	_reset_ui_positions()
	
	match layout_type:
		LayoutType.SMALL:
			_apply_small_layout()
		LayoutType.MEDIUM:
			_apply_medium_layout()
		LayoutType.LARGE:
			_apply_large_layout()
		LayoutType.WIDE:
			_apply_wide_layout()
		LayoutType.NARROW:
			_apply_narrow_layout()

func _reset_ui_positions():
	# Reset HUD
	if hud:
		hud.anchors_preset = Control.PRESET_TOP_LEFT
		hud.offset_right = 0
		hud.offset_bottom = 0
	
	# Reset inventory
	if inventory:
		inventory.anchors_preset = Control.PRESET_TOP_RIGHT
		inventory.offset_left = -227
		inventory.offset_right = 0
		inventory.offset_top = 0
		inventory.offset_bottom = 156

# Different layout implementations
func _apply_small_layout():
	if hud:
		# Make HUD smaller and compact
		hud.custom_minimum_size.x = max(200, DisplayServer.window_get_size().x * 0.15)
	
	if inventory:
		# Shrink inventory
		inventory.scale = Vector2(0.8, 0.8)
		inventory.offset_left = -180

func _apply_medium_layout():
	if hud:
		# Standard HUD size for medium screens
		hud.custom_minimum_size.x = max(220, DisplayServer.window_get_size().x * 0.18)
	
	if inventory:
		# Adjust inventory
		inventory.scale = Vector2(0.9, 0.9)
		inventory.offset_left = -210

func _apply_large_layout():
	if hud:
		# Full size HUD
		hud.custom_minimum_size.x = max(250, DisplayServer.window_get_size().x * 0.2)
	
	if inventory:
		# Default inventory size
		inventory.scale = Vector2(1.0, 1.0)
		inventory.offset_left = -227

func _apply_wide_layout():
	if hud:
		# For ultrawide: potentially move HUD more to the side
		hud.custom_minimum_size.x = max(250, DisplayServer.window_get_size().x * 0.15)
	
	if inventory:
		# For ultrawide: give inventory more space
		inventory.scale = Vector2(1.0, 1.0)
		inventory.offset_left = -250

func _apply_narrow_layout():
	if hud:
		# For narrow screens: make HUD narrower
		hud.custom_minimum_size.x = max(200, DisplayServer.window_get_size().x * 0.25)
	
	if inventory:
		# For narrow screens: adjust inventory placement
		inventory.scale = Vector2(0.9, 0.9)
		inventory.offset_left = -200

# Sets tooltip settings globally for all controls
func _set_global_tooltip_settings():
	# Set global tooltip delay to 0 (immediate) through project settings
	ProjectSettings.set_setting("gui/timers/tooltip_delay_sec", 0)
	
	# Create a theme for font size
	var theme = Theme.new()
	theme.set_font_size("font_size", "TooltipLabel", 18)
	
	# Set as default theme for this scene
	get_tree().root.theme = theme
	
	# Apply the tooltip font size to all controls recursively
	_apply_tooltip_font_size(get_tree().root)

# Recursively apply tooltip font size to all controls
func _apply_tooltip_font_size(node):
	if node is Control:
		# Apply theme override for tooltip font size
		node.add_theme_font_size_override("tooltip_font_size", 18)
	
	# Process children recursively
	for child in node.get_children():
		_apply_tooltip_font_size(child)