extends Node

const SAVE_FILE_PATH = "user://savegame.save"

# Save all game data
func save_game() -> bool:
	var save_dict = {
		"version": 1,  # Save version for future compatibility
		"timestamp": Time.get_unix_time_from_system(),
		
		# Game state data
		"depth": GameState.depth,
		"max_depth_reached": GameState.maxDepthReached,
		"money": GameState.money,
		"health": GameState.health,
		"player_in_stage": GameState.playerInStage,
		
		# Upgrades
		"upgrades": {},
		
		# Inventory
		"inventory_items": []
	}
	
	# Save all upgrades
	for upgrade in GameState.upgrades:
		save_dict["upgrades"][str(upgrade)] = GameState.upgrades[upgrade]
	
	# Save inventory items
	for item in GameState.inventory.items:
		var item_data = {
			"id": item.id,
			"type": item.type,
			"weight": item.weight,
			"price": item.price,
			"shiny": item.shiny
		}
		save_dict["inventory_items"].append(item_data)
	
	# Save inventory stats
	save_dict["inventory_cumulated_values"] = {
		"fishes_caught": GameState.inventory.inventoryCumulatedValues[GameState.inventory.InventoryValues.FishesCaught],
		"total_weight": GameState.inventory.inventoryCumulatedValues[GameState.inventory.InventoryValues.TotalWeight],
		"total_value": GameState.inventory.inventoryCumulatedValues[GameState.inventory.InventoryValues.TotalValue]
	}
	
	# Create save file
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file == null:
		var error = FileAccess.get_open_error()
		print("Error opening save file: ", error)
		return false
	
	# Convert dictionary to JSON string and save
	var json_string = JSON.stringify(save_dict)
	save_file.store_string(json_string)
	save_file.close()
	
	print("Game saved successfully")
	return true

# Load saved game data
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file found")
		return false
	
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if save_file == null:
		var error = FileAccess.get_open_error()
		print("Error opening save file: ", error)
		return false
	
	var json_string = save_file.get_as_text()
	save_file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
		return false
	
	var save_dict = json.get_data()
	
	# Verify save version
	if save_dict.has("version"):
		var version = save_dict["version"]
		if version != 1:
			print("Warning: Save file version mismatch. Expected 1, got ", version)
	
	# Load game state
	if save_dict.has("depth"):
		GameState.setDepth(save_dict["depth"])
	
	if save_dict.has("max_depth_reached"):
		GameState.maxDepthReached = save_dict["max_depth_reached"]
	
	if save_dict.has("money"):
		GameState.money = save_dict["money"]
	
	if save_dict.has("health"):
		GameState.health = save_dict["health"]
	
	# Load upgrades
	if save_dict.has("upgrades"):
		for upgrade_key in save_dict["upgrades"]:
			var upgrade_val = int(upgrade_key)
			GameState.upgrades[upgrade_val] = save_dict["upgrades"][upgrade_key]
	
	# Clear and load inventory
	GameState.inventory.items.clear()
	
	if save_dict.has("inventory_items"):
		for item_data in save_dict["inventory_items"]:
			var inv_item = InvItem.new()
			inv_item.id = item_data["id"]
			inv_item.type = item_data["type"]
			inv_item.weight = item_data["weight"]
			inv_item.price = item_data["price"]
			inv_item.shiny = item_data["shiny"]
			
			GameState.inventory.items.append(inv_item)
	
	# Load inventory stats
	if save_dict.has("inventory_cumulated_values"):
		var inv_values = save_dict["inventory_cumulated_values"]
		
		if inv_values.has("fishes_caught"):
			GameState.inventory.inventoryCumulatedValues[GameState.inventory.InventoryValues.FishesCaught] = inv_values["fishes_caught"]
		
		if inv_values.has("total_weight"):
			GameState.inventory.inventoryCumulatedValues[GameState.inventory.InventoryValues.TotalWeight] = inv_values["total_weight"]
		
		if inv_values.has("total_value"):
			GameState.inventory.inventoryCumulatedValues[GameState.inventory.InventoryValues.TotalValue] = inv_values["total_value"]
	
	GameState.inventory.updateTotal()
	
	print("Game loaded successfully")
	return true

# Delete save file
func delete_save() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file to delete")
		return false
	
	var dir = DirAccess.open("user://")
	if dir == null:
		var error = DirAccess.get_open_error()
		print("Error opening directory: ", error)
		return false
	
	var error = dir.remove(SAVE_FILE_PATH)
	if error != OK:
		print("Error deleting save file: ", error)
		return false
	
	print("Save file deleted successfully")
	return true

# Check if a save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

# Get save file info (for showing in menu)
func get_save_info() -> Dictionary:
	if not has_save_file():
		return {}
	
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if save_file == null:
		return {}
	
	var json_string = save_file.get_as_text()
	save_file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		return {}
	
	var save_dict = json.get_data()
	
	var save_info = {
		"timestamp": save_dict.get("timestamp", 0),
		"depth": save_dict.get("depth", 0),
		"max_depth": save_dict.get("max_depth_reached", 0),
		"money": save_dict.get("money", 0)
	}
	
	return save_info 