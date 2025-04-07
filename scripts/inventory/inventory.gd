extends Resource

class_name Inv

@export var items: Array[InvItem]
enum InventoryValues {FishesCaught, TotalWeight, TotalValue}
var inventoryCumulatedValues = {
	InventoryValues.FishesCaught: 0,
	InventoryValues.TotalWeight: 0,
	InventoryValues.TotalValue: 0,
}
@export var max_weight = 100

func add(item: InvItem):
	for i in GameState.inventory.items:
		if i.id == item.id:
			print("Duplicate fish ID detected: ", item.id)
			return false
	items.append(item)
	updateTotal()
	return true

func sellItems():
	while 0 < GameState.inventory.items.size():
		var item = GameState.inventory.items[0]
		GameState.money += item.price
		GameState.inventory.items.remove_at(0)
	updateTotal()

func updateTotal():
	var totalPrice = 0
	var totalWeight = 0
	var n = 0
	for item in GameState.inventory.items:
		totalPrice += item.price
		totalWeight += item.weight
		n =+ 1
		
	inventoryCumulatedValues[InventoryValues.TotalValue] = totalPrice
	inventoryCumulatedValues[InventoryValues.TotalWeight] = totalWeight
	inventoryCumulatedValues[InventoryValues.FishesCaught] = items.size()
