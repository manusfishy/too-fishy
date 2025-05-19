extends PanelContainer

var is_open = false

# Onready vars for UI elements
@onready var money_label = $MarginContainer/VBoxContainer/MoneyPanel/MoneyLabel
@onready var fish_label = $MarginContainer/VBoxContainer/InfoPanel/HBoxContainer/FishLabel
@onready var value_label = $MarginContainer/VBoxContainer/InfoPanel/HBoxContainer/ValueLabel
@onready var weight_label = $MarginContainer/VBoxContainer/WeightPanel/VBoxContainer/HBoxContainer/WeightValueLabel
@onready var weight_bar = $MarginContainer/VBoxContainer/WeightPanel/WeightBar
@onready var vbox_container = $MarginContainer/VBoxContainer

# Base sizes
var base_panel_width = 220
var base_panel_height = 125
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
	scale_factor = max(0.75, scale_factor) # don't go below 75%
	
	# Scale font sizes
	var font_scale = lerp(0.8, 1.0, scale_factor)
	money_label.add_theme_font_size_override("font_size", int(16 * font_scale))
	fish_label.add_theme_font_size_override("font_size", int(16 * font_scale))
	value_label.add_theme_font_size_override("font_size", int(16 * font_scale))
	weight_label.add_theme_font_size_override("font_size", int(14 * font_scale))
	
	# Adjust panel size based on content and screen size
	custom_minimum_size = Vector2(base_panel_width * scale_factor, 0) # Let height adjust automatically
	
	# Update base font size for dynamically created elements
	base_font_size = int(16 * font_scale)

func _process(_delta):
	if Input.is_action_just_pressed("inv_toggle"):
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
	# Update static UI elements with current data
	money_label.text = "Bank Account: %s$ " % GameState.money
	fish_label.text = " Fish: %d " % \
		GameState.inventory.inventoryCumulatedValues[GameState.inventory.InventoryValues.FishesCaught]
	value_label.text = "$%.2f " % \
		GameState.inventory.inventoryCumulatedValues[GameState.inventory.InventoryValues.TotalValue]
	
	# Update weight display with both text and progress bar
	var current_weight = GameState.inventory.inventoryCumulatedValues[GameState.inventory.InventoryValues.TotalWeight]
	var max_weight = GameState.inventory.get_max_weight()
	weight_label.text = "%.1f / %.1f " % [current_weight, max_weight]
	
	# Update progress bar
	weight_bar.max_value = max_weight
	weight_bar.value = current_weight
	
	# Change color based on capacity
	var fill_style = weight_bar.get_theme_stylebox("fill")
	if fill_style is StyleBoxFlat:
		var ratio = current_weight / max_weight
		if ratio > 0.7:
			fill_style.bg_color = Color(0.918, 0.212, 0.212, 0.82) # Red when nearly full
		elif ratio > 0.5:
			fill_style.bg_color = Color(0.918, 0.525, 0.212, 0.82) # Orange when moderately full
		else:
			fill_style.bg_color = Color(0, 0.36, 0.83, 0.8) # Blue when plenty of space
	
	# Clear any existing upgrade panels
	for child in vbox_container.get_children():
		if child.name.begins_with("UpgradePanel"):
			child.queue_free()
	
	# Add upgrade info if player has purchased upgrades
	var has_purchased_upgrades = false
	
	# Now add any upgrades the player has purchased
	for upgrade in GameState.Upgrade.values():
		if GameState.upgrades[upgrade] > 0:
			has_purchased_upgrades = true
			add_upgrade_info(upgrade, Strings.upgradeDescriptions[upgrade])

# Helper function to add upgrade info with status
func add_upgrade_info(upgrade_type, description):
	if GameState.upgrades[upgrade_type] > 0:
		# Extract just the name and key from the description
		var parts = description.split(":")
		if parts.size() >= 2:
			var desc_name = parts[0].strip_edges()
			var key = parts[1].strip_edges()
			
			# Create compact upgrade panel
			var upgrade_panel = PanelContainer.new()
			upgrade_panel.name = "UpgradePanel" + str(upgrade_type)
			
			# Get the same style as other panels
			var style = $MarginContainer/VBoxContainer/InfoPanel.get_theme_stylebox("panel")
			if style:
				upgrade_panel.add_theme_stylebox_override("panel", style)
			
			# Use horizontal layout for compact display
			var h_box = HBoxContainer.new()
			h_box.alignment = BoxContainer.ALIGNMENT_CENTER
			
			# Create label with upgrade name
			var name_label = Label.new()
			name_label.text = desc_name + ":"
			name_label.add_theme_font_size_override("font_size", base_font_size)
			name_label.add_theme_color_override("font_color", Color(0.780392, 0.780392, 0.780392, 1))
			name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			# Create label with upgrade value
			var value_up_label = Label.new()
			value_up_label.text = key
			value_up_label.add_theme_font_size_override("font_size", base_font_size)
			value_up_label.add_theme_color_override("font_color", Color(0.105882, 0.85098, 0.917647, 1))
			value_up_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			value_up_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			
			# Add to layout
			h_box.add_child(name_label)
			h_box.add_child(value_up_label)
			upgrade_panel.add_child(h_box)
			vbox_container.add_child(upgrade_panel)
