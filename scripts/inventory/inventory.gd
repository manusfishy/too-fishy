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
		
	# Sort inventory items by price (lowest first)
	var sorted_items = items.duplicate()
	sorted_items.sort_custom(func(a, b): return a.price < b.price)
	
	# First, check if a single fish replacement is possible (most efficient case)
	for item in sorted_items:
		# If a single fish is more valuable than the new one, skip it
		if item.price >= new_fish.price:
			continue
			
		# Check if removing just this fish would free enough space
		if item.weight >= new_fish.weight:
			# This one fish is enough - replace it
			release_fish(item)
			items.erase(item)
			items.append(new_fish)
			updateTotal()
			return true
	
	# If we need multiple fish, try to find the optimal combination
	# We'll use a greedy approach that prioritizes value efficiency
	
	# Calculate space needed
	var space_needed = new_fish.weight - (get_max_weight() - inventoryCumulatedValues[InventoryValues.TotalWeight])
	if space_needed <= 0:
		# This shouldn't happen, but just in case
		items.append(new_fish)
		updateTotal()
		return true
		
	# Sort by price-to-weight ratio (least valuable per weight first)
	sorted_items.sort_custom(func(a, b):
		return (a.price / float(a.weight)) < (b.price / float(b.weight))
	)
	
	var fish_to_remove = []
	var total_weight_to_remove = 0
	var total_value_to_remove = 0
	
	# Add fish until we have enough space, starting with least valuable per weight
	for item in sorted_items:
		fish_to_remove.append(item)
		total_weight_to_remove += item.weight
		total_value_to_remove += item.price
		
		# Check if we've freed enough space
		if total_weight_to_remove >= space_needed:
			# Only proceed if new fish is more valuable than sum of removed fish
			if new_fish.price > total_value_to_remove:
				# Remove the selected fish and release them back into the water
				for fish in fish_to_remove:
					release_fish(fish)
					items.erase(fish)
				
				# Add the new fish
				items.append(new_fish)
				updateTotal()
				return true
			else:
				# Try with a different combination - let's check subsets
				# This handles cases where a smaller subset might be more efficient
				var subset = find_optimal_subset(sorted_items, space_needed, new_fish.price)
				if subset.size() > 0:
					# Found a more efficient subset
					for fish in subset:
						release_fish(fish)
						items.erase(fish)
					
					# Add the new fish
					items.append(new_fish)
					updateTotal()
					return true
			return false
	
	return false

# Helper function to find an optimal subset of fish to remove
func find_optimal_subset(sorted_fish: Array, space_needed: float, new_fish_price: int) -> Array:
	# Try different combinations of fish, prioritizing those with least value per weight
	var best_subset = []
	var best_efficiency = 0 # Higher is better
	
	# Try all possible subsets (this is simplified and not a true knapsack solver)
	# We'll limit to checking pairs for performance reasons
	for i in range(sorted_fish.size()):
		var fish1 = sorted_fish[i]
		
		# Skip if fish1 is too valuable
		if fish1.price >= new_fish_price:
			continue
			
		# Try just this fish
		if fish1.weight >= space_needed:
			var efficiency = new_fish_price - fish1.price
			if efficiency > best_efficiency:
				best_efficiency = efficiency
				best_subset = [fish1]
				
		# Try pairs of fish
		for j in range(i + 1, sorted_fish.size()):
			var fish2 = sorted_fish[j]
			
			# Skip if the pair is too valuable
			if fish1.price + fish2.price >= new_fish_price:
				continue
				
			# Check if this pair frees enough space
			if fish1.weight + fish2.weight >= space_needed:
				var combined_price = fish1.price + fish2.price
				var efficiency = new_fish_price - combined_price
				
				if efficiency > best_efficiency:
					best_efficiency = efficiency
					best_subset = [fish1, fish2]
	
	return best_subset

# Function to release a fish from inventory back into the water
func release_fish(fish_item: InvItem) -> void:
	# Get player position (submarine location)
	var player = GameState.player_node
	if player == null:
		return
		
	# Determine which fish type to spawn based on price/weight ratio
	var price_per_weight = fish_item.price / float(fish_item.weight)
	var fish_type = FishesConfig.FishType.FISH_A # Default type
	
	# Find the closest matching fish type based on price/weight ratio
	var best_match_diff = INF
	for type in FishesConfig.fishConfigMap:
		var config = FishesConfig.fishConfigMap[type]
		var avg_weight = (config.weight_min + config.weight_max) / 2.0
		var avg_price = avg_weight * config.price_weight_multiplier
		var config_ratio = avg_price / avg_weight
		
		var diff = abs(config_ratio - price_per_weight)
		if diff < best_match_diff:
			best_match_diff = diff
			fish_type = type
	
	# Create and position the fish
	var fish_config = FishesConfig.fishConfigMap[fish_type]
	var fish_scene = fish_config.scene
	var fish = fish_scene.instantiate()
	
	# Random position near the submarine
	var spawn_offset = Vector3(
		randf_range(-1.5, 1.5),
		randf_range(-1.0, 1.0),
		0
	)
	var spawn_pos = player.global_position + spawn_offset
	spawn_pos.z = -0.3 # Standard z-depth for fish
	
	# Calculate if fish should be shiny based on price/weight ratio
	var is_shiny = price_per_weight > (fish_config.price_weight_multiplier * 2)
	
	# Initialize the fish with properties similar to the inventory item
	fish.initialize(
		spawn_pos,
		0, # No home section
		fish_config.speed_min,
		fish_config.speed_max,
		fish_config.difficulty,
		fish_item.weight * 0.8, # Use similar weight as the inventory item
		fish_item.weight * 1.2,
		fish_config.price_weight_multiplier,
		fish_type,
		1.0, # Normal weight multiplier
		is_shiny
	)
	
	# Add fish to the world
	player.get_parent().add_child(fish)
	
	# Make the fish scatter away from the submarine
	if fish.has_method("scatter"):
		fish.scatter(player)

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
