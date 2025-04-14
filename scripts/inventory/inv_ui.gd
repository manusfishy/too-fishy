extends PanelContainer

var is_open = false

@onready var grid = $VBoxContainer/GridContainer

func _ready():
	update_display()
	open()

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
	if Input.is_action_just_pressed("esc"):
		close()

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
	
	# Create text elements
	var fishes_text = Label.new()
	fishes_text.text = "Stored fish: %d" % \
			GameState.inventory.inventoryCumulatedValues[GameState.inventory.InventoryValues.FishesCaught]
	grid.add_child(fishes_text)
	
	var weight_text = Label.new()
	weight_text.text = "Total weight: %.1f / %.1f" % \
			[GameState.inventory.inventoryCumulatedValues[GameState.inventory.InventoryValues.TotalWeight], \
			GameState.inventory.get_max_weight()]
	grid.add_child(weight_text)
	
	var value_text = Label.new()
	value_text.text = "Total value: $%.2f" % \
			GameState.inventory.inventoryCumulatedValues[GameState.inventory.InventoryValues.TotalValue]
	grid.add_child(value_text)
	
	# Add separator
	var separator = HSeparator.new()
	grid.add_child(separator)
	
	# Add information about new upgrades
	var upgrades_title = Label.new()
	upgrades_title.text = "Purchased Upgrades:"
	grid.add_child(upgrades_title)
	
	# Harpoon Rotation upgrade
	add_upgrade_info(GameState.Upgrade.HARPOON_ROTATION, "Rotatable Harpoon: Aim with mouse or touch")
	
	# Inventory Management upgrade
	add_upgrade_info(GameState.Upgrade.INVENTORY_MANAGEMENT, "Smart Inventory: Replaces less valuable fish")
	
	# Surface Buoy upgrade
	add_upgrade_info(GameState.Upgrade.SURFACE_BUOY, "Emergency Buoy: Press B to return to surface")
	
	# Inventory Save upgrade
	add_upgrade_info(GameState.Upgrade.INVENTORY_SAVE, "Inventory Insurance: Keeps items after death")
	
	# Drone Selling upgrade
	add_upgrade_info(GameState.Upgrade.DRONE_SELLING, "Remote Selling Drone: Press C to sell remotely")

# Helper function to add upgrade info with status
func add_upgrade_info(upgrade_type, description):
	if GameState.upgrades[upgrade_type] > 0:
		var upgrade_label = Label.new()
		upgrade_label.text = "✓ " + description
		grid.add_child(upgrade_label)
	elif GameState.isDocked:
		# Only show unpurchased upgrades when docked
		var upgrade_label = Label.new()
		upgrade_label.text = "□ " + description + " ($" + str(GameState.getUpgradeCost(upgrade_type)) + ")"
		grid.add_child(upgrade_label)
