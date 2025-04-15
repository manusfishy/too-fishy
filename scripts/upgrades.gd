extends PanelContainer

var buttons = {}
var description_panel = null
var description_label = null
var upgrade_descriptions = null

# List of the 5 new upgrades that should be hidden until purchased
var new_upgrades = [
	GameState.Upgrade.HARPOON_ROTATION,
	GameState.Upgrade.INVENTORY_MANAGEMENT,
	GameState.Upgrade.SURFACE_BUOY,
	GameState.Upgrade.INVENTORY_SAVE,
	GameState.Upgrade.DRONE_SELLING
]

func _ready():
	# Set a fixed size for the entire panel to prevent resizing
	custom_minimum_size = Vector2(400, 400)
	
	# Load descriptions once at initialization
	upgrade_descriptions = load("res://scripts/upgrade_descriptions.gd").new()
	
	# Create description panel
	create_description_panel()
	
	# Create upgrade buttons with tooltips
	for key in GameState.upgrades:
		# Skip the 5 new upgrades if they haven't been purchased yet
		if key in new_upgrades and GameState.upgrades[key] == 0:
			continue
			
		var upgradeButton: Button = Button.new()
		upgradeButton.text = Strings.upgradeNames[key] + " %s" % (GameState.upgrades[key] + 1) + " (Cost: %s)" % GameState.getUpgradeCost(key)
		upgradeButton.pressed.connect(func(): GameState.upgrade(key))
		upgradeButton.mouse_entered.connect(func(): show_description(key))
		upgradeButton.mouse_exited.connect(func(): hide_description())
		
		# Center the text in the button
		upgradeButton.alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		# For mobile support, also show description on focus
		upgradeButton.focus_entered.connect(func(): show_description(key))
		upgradeButton.focus_exited.connect(func(): hide_description())
		
		$VBoxContainer/GridContainer.add_child(upgradeButton)
		buttons[key] = upgradeButton

func create_description_panel():
	# Create a panel to display upgrade descriptions
	description_panel = PanelContainer.new()
	description_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	description_panel.custom_minimum_size = Vector2(300, 150)
	
	# Always reserve space for the description panel, even when hidden
	description_panel.visible = true
	description_panel.modulate = Color(1, 1, 1, 0)  # Transparent but still takes up space
	
	# Add a margin container for padding
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	description_panel.add_child(margin)
	
	# Add a label for the description text
	description_label = Label.new()
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.size_flags_vertical = SIZE_EXPAND_FILL
	
	# Center the description text
	# Label objects use horizontal_alignment, not alignment
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	margin.add_child(description_label)
	
	# Add the panel to the UI
	$VBoxContainer.add_child(description_panel)

func show_description(upgrade_key):
	# Set the description text using the pre-loaded descriptions
	if upgrade_descriptions and upgrade_descriptions.upgradeDescriptions.has(upgrade_key):
		description_label.text = upgrade_descriptions.upgradeDescriptions[upgrade_key]
		# Make panel visible by setting opacity to 1
		description_panel.modulate = Color(1, 1, 1, 1)
	else:
		# Handle error case
		description_label.text = "Description not available"
		description_panel.modulate = Color(1, 1, 1, 1)

func hide_description():
	# Hide the description panel by making it transparent
	description_panel.modulate = Color(1, 1, 1, 0)

func _process(_delta):
	if GameState.isDocked:
		visible = true
		
		# Check if any new upgrades were purchased and need to be added
		for key in new_upgrades:
			if GameState.upgrades[key] > 0 and not buttons.has(key):
				var upgradeButton: Button = Button.new()
				upgradeButton.text = Strings.upgradeNames[key] + " %s" % (GameState.upgrades[key] + 1) + " (Cost: %s)" % GameState.getUpgradeCost(key)
				upgradeButton.pressed.connect(func(): GameState.upgrade(key))
				upgradeButton.mouse_entered.connect(func(): show_description(key))
				upgradeButton.mouse_exited.connect(func(): hide_description())
				
				# Center the text in the button
				upgradeButton.alignment = HORIZONTAL_ALIGNMENT_CENTER
				
				# For mobile support, also show description on focus
				upgradeButton.focus_entered.connect(func(): show_description(key))
				upgradeButton.focus_exited.connect(func(): hide_description())
				
				$VBoxContainer/GridContainer.add_child(upgradeButton)
				buttons[key] = upgradeButton
	else:
		visible = false
		
	for key in buttons:
		var upgradeButton = buttons[key]
		
		if GameState.upgrades[key] == GameState.maxUpgrades[key]:
			upgradeButton.text = Strings.upgradeNames[key] + "[MAX]"
		else:
			upgradeButton.text = Strings.upgradeNames[key] + " %s" % (GameState.upgrades[key] + 1) + " (Cost: %s)" % GameState.getUpgradeCost(key)
