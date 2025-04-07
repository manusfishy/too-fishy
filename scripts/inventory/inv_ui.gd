extends PanelContainer

var is_open = false

@onready var grid = $VBoxContainer/GridContainer

func _ready():
	update_display()
	close()

func _process(delta):
	if GameState.isDocked:
		close()
	if Input.is_action_just_pressed("inv_toggle"):
		if GameState.isDocked:
			return
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
