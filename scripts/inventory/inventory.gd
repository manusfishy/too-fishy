extends Resource

class_name Inv

@export var items: Array[InvItem]

func add(item: InvItem):
	items.append(item)

func sellItems():
	while 0 < GameState.inventory.items.size():
		var item = GameState.inventory.items[0]
		GameState.money += item.price
		GameState.inventory.items.remove_at(0)
