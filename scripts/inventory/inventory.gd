extends Resource

class_name Inv

@export var items: Array[InvItem]

func add(item: InvItem):
	for i in GameState.inventory.items:
		if i.id == item.id:
			print("Duplicate fish ID detected: ", item.id)
			return false
	items.append(item)
	return true

func sellItems():
	while 0 < GameState.inventory.items.size():
		var item = GameState.inventory.items[0]
		GameState.money += item.price
		GameState.inventory.items.remove_at(0)
