extends PanelContainer

var buttons = {}
var description_panel = null
var description_label = null
var upgrade_descriptions = null

func _ready():
	# Load descriptions once at initialization
	upgrade_descriptions = load("res://scripts/upgrade_descriptions.gd").new()
	
	# Create description panel
	create_description_panel()
	
	# Create upgrade buttons with tooltips
	for key in GameState.upgrades:
		var upgradeButton: Button = Button.new()
		upgradeButton.text = Strings.upgradeNames[key] + " %s" % (GameState.upgrades[key] + 1) + " (Cost: %s)" % GameState.getUpgradeCost(key)
		upgradeButton.pressed.connect(func(): GameState.upgrade(key))
		upgradeButton.mouse_entered.connect(func(): show_description(key))
		upgradeButton.mouse_exited.connect(func(): hide_description())
		
		# For mobile support, also show description on focus
		upgradeButton.focus_entered.connect(func(): show_description(key))
		upgradeButton.focus_exited.connect(func(): hide_description())
		
		$VBoxContainer/GridContainer.add_child(upgradeButton)
		buttons[key] = upgradeButton

func create_description_panel():
	# Create a panel to display upgrade descriptions
	description_panel = PanelContainer.new()
	description_panel.visible = false
	description_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	description_panel.custom_minimum_size = Vector2(300, 100)
	
	# Add a margin container for padding
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	description_panel.add_child(margin)
	
	# Add a label for the description text
	description_label = Label.new()
	description_label.autowrap = true
	description_label.size_flags_vertical = SIZE_EXPAND_FILL
	margin.add_child(description_label)
	
	# Add the panel to the UI
	$VBoxContainer.add_child(description_panel)

func show_description(upgrade_key):
	# Set the description text using the pre-loaded descriptions
	if upgrade_descriptions and upgrade_descriptions.upgradeDescriptions.has(upgrade_key):
		description_label.text = upgrade_descriptions.upgradeDescriptions[upgrade_key]
		description_panel.visible = true
	else:
		# Handle error case
		description_label.text = "Description not available"
		description_panel.visible = true

func hide_description():
	# Hide the description panel
	description_panel.visible = false

func _process(_delta):
	if GameState.isDocked:
		visible = true
	else:
		visible = false
	for key in buttons:
		var upgradeButton = buttons[key]
		
		if GameState.upgrades[key] == GameState.maxUpgrades[key]:
			upgradeButton.text = Strings.upgradeNames[key] + "[MAX]"
		else:
			upgradeButton.text = Strings.upgradeNames[key] + " %s" % (GameState.upgrades[key] + 1) + " (Cost: %s)" % GameState.getUpgradeCost(key)
