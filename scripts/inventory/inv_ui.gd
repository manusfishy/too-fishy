extends PanelContainer

var is_open = false

@onready var grid = $VBoxContainer/GridContainer
@onready var title_label = $VBoxContainer/Label

# Base sizes
var base_panel_width = 279
var base_panel_height = 165
var base_font_size = 16

func _ready():
	update_display()
	open()
	
	# Connect to window resize signal
	get_viewport().size_changed.connect(_adjust_ui_scale)
	
	# Initial scale adjustment
	_adjust_ui_scale()

func _adjust_ui_scale():
	var window_size = DisplayServer.window_get_size()
	
	# Calculate scale factor based on screen size
	var scale_factor = min(window_size.x / 1920.0, window_size.y / 1080.0)
	scale_factor = max(0.75, scale_factor)  # don't go below 75%
	
	# Scale font sizes
	var font_scale = lerp(0.8, 1.0, scale_factor)
	title_label.add_theme_font_size_override("font_size", int(base_font_size * 1.2 * font_scale))
	
	# Adjust panel size based on content and screen size
	custom_minimum_size = Vector2(base_panel_width * scale_factor, 0)  # Let height adjust automatically
	
	# Update font sizes for dynamic elements (will be applied on next update_display call)
	base_font_size = int(16 * font_scale)

func _process(_delta):
	#if GameState.isDocked:
	#	close()
	if Input.is_action_just_pressed("inv_toggle"):
		#if GameState.isDocked:
		#	return
		if is_open:
			close()
		else:
			open()
	if is_open:
		update_display()

func open():
	visible = true
	is_open = true
	update_display()

func close():
	visible = false
	is_open = false

func update_display():
	# Clear existing children (except any permanent ones you might have)
	for child in grid.get_children():
		child.queue_free()
	
	# Create text elements with scaled fonts
	# Money display moved from HUD to inventory
	var money_text = Label.new()
	money_text.text = "Money: %s" % GameState.money
	money_text.add_theme_font_size_override("font_size", base_font_size)
	grid.add_child(money_text)
	
	var fishes_text = Label.new()
	fishes_text.text = "Stored fish: %d" % \
			GameState.inventory.inventoryCumulatedValues[GameState.inventory.InventoryValues.FishesCaught]
	fishes_text.add_theme_font_size_override("font_size", base_font_size)
	grid.add_child(fishes_text)
	
	var weight_text = Label.new()
	weight_text.text = "Total weight: %.1f / %.1f" % \
			[GameState.inventory.inventoryCumulatedValues[GameState.inventory.InventoryValues.TotalWeight], \
			GameState.inventory.get_max_weight()]
	weight_text.add_theme_font_size_override("font_size", base_font_size)
	grid.add_child(weight_text)
	
	var value_text = Label.new()
	value_text.text = "Total value: $%.2f" % \
			GameState.inventory.inventoryCumulatedValues[GameState.inventory.InventoryValues.TotalValue]
	value_text.add_theme_font_size_override("font_size", base_font_size)
	grid.add_child(value_text)
	
	# Add separator
	var separator = HSeparator.new()
	grid.add_child(separator)
	
	var has_purchased_upgrades = false

# Helper function to add upgrade info with status
func add_upgrade_info(upgrade_type, description):
	if GameState.upgrades[upgrade_type] > 0:
		# Extract just the name and key from the description
		var parts = description.split(":")
		if parts.size() >= 2:
			var name = parts[0].strip_edges()
			var key = parts[1].strip_edges()
			
			var upgrade_label = Label.new()
			upgrade_label.text = name + ": " + key
			upgrade_label.add_theme_font_size_override("font_size", base_font_size)
			grid.add_child(upgrade_label)
	# Don't show anything for items the player doesn't have
