extends PanelContainer

var is_open = false

enum InventoryValues {FishesCaught, TotalWeight, TotalValue}
var inventory = {
	InventoryValues.FishesCaught: 0,
	InventoryValues.TotalWeight: 0,
	InventoryValues.TotalValue: 0,
}

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
		getTotal()
		update_display()
	if Input.is_action_just_pressed("esc"):
		close()
		

func open():
	visible = true
	is_open = true
	getTotal()
	update_display()

func close():
	visible = false
	is_open = false

func getTotal():
	var totalPrice = 0
	var totalWeight = 0
	var n = 0
	for item in GameState.inventory.items:
		totalPrice += item.price
		totalWeight += item.weight
		n =+ 1
		
	inventory[InventoryValues.TotalValue] = totalPrice
	inventory[InventoryValues.TotalWeight] = totalWeight
	inventory[InventoryValues.FishesCaught] = GameState.inventory.items.size()

func update_display():
	# Clear existing children (except any permanent ones you might have)
	for child in grid.get_children():
		child.queue_free()
	
	# Create text elements
	var fishes_text = Label.new()
	fishes_text.text = "Fishes: %d" % inventory[InventoryValues.FishesCaught]
	grid.add_child(fishes_text)
	
	var weight_text = Label.new()
	weight_text.text = "Weight: %.1f kg" % inventory[InventoryValues.TotalWeight]
	grid.add_child(weight_text)
	
	var value_text = Label.new()
	value_text.text = "Value: $%.2f" % inventory[InventoryValues.TotalValue]
	grid.add_child(value_text)
