extends Resource

class_name Inv

@export var items: Array[InvItem]
enum InventoryValues {FishesCaught, TotalWeight, TotalValue}
var inventoryCumulatedValues = {
	InventoryValues.FishesCaught: 0,
	InventoryValues.TotalWeight: 0,
	InventoryValues.TotalValue: 0,
}

func get_max_weight() -> int:
	var cargo_level = (GameState.upgrades[GameState.Upgrade.CARGO_SIZE] + 1)
	
	if cargo_level <= 4:
		return 25 * cargo_level;
	else:
		return 100 + 50 * (cargo_level - 4)

func add(item: InvItem):
	for i in GameState.inventory.items:
		if i.id == item.id:
			print("Duplicate fish ID detected: ", item.id)
			return false
	
	# Check if inventory is full
	if item.weight + inventoryCumulatedValues[InventoryValues.TotalWeight] > get_max_weight():
		# If inventory management upgrade is purchased, try to replace less valuable fish
		if GameState.upgrades[GameState.Upgrade.INVENTORY_MANAGEMENT] > 0:
			return try_replace_less_valuable_fish(item)
		return false
	else:
		items.append(item)
		updateTotal()
		return true
		
# Function to replace less valuable fish with more expensive ones
func try_replace_less_valuable_fish(new_fish: InvItem) -> bool:
	# If inventory is empty, can't replace anything
	if items.size() == 0:
		return false
		
	# Find the least valuable fish in inventory
	var least_valuable_index = 0
	var least_valuable_price = items[0].price
	
	for i in range(items.size()):
		if items[i].price < least_valuable_price:
			least_valuable_index = i
			least_valuable_price = items[i].price
	
	# Only replace if the new fish is more valuable
	if new_fish.price > least_valuable_price:
		# Check if removing the least valuable fish and adding the new one would fit
		var new_weight = inventoryCumulatedValues[InventoryValues.TotalWeight] - items[least_valuable_index].weight + new_fish.weight
		
		if new_weight <= get_max_weight():
			# Replace the fish
			items.remove_at(least_valuable_index)
			items.append(new_fish)
			updateTotal()
			return true
	
	return false
	

func sellItems():
	var sold = 0
	while 0 < GameState.inventory.items.size():
		var item = GameState.inventory.items[0]
		sold += item.price
		GameState.inventory.items.remove_at(0)
	GameState.money += sold
	updateTotal()
	return sold

func updateTotal():
	var totalPrice = 0
	var totalWeight = 0
	for item in GameState.inventory.items:
		totalPrice += item.price
		totalWeight += item.weight
		
	inventoryCumulatedValues[InventoryValues.TotalValue] = totalPrice
	inventoryCumulatedValues[InventoryValues.TotalWeight] = totalWeight
	inventoryCumulatedValues[InventoryValues.FishesCaught] = items.size()
	
func clear() -> void:
	items.clear()
	updateTotal()
