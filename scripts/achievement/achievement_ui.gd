extends Control

# References to UI elements
var achievement_container: VBoxContainer
var achievement_system: AchievementSystem

# Preload icons
var questionmark = preload("res://textures/icons/questionmark.png")
var star = preload("res://textures/icons/pure_star.png")
var air_bubble = preload("res://textures/icons/air_bubble.png")

# Achievement item scene
var achievement_item_scene = preload("res://scenes/ui/achievement_item.tscn")

func _ready():
	achievement_container = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/AchievementContainer
	
	# Make sure all UI elements ignore mouse input
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$PanelContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Make sure panel is visible
	visible = true
	
	# Wait a bit to ensure autoloads are fully initialized
	call_deferred("_connect_to_achievement_system")

# Attempt to find and connect to the achievement system
func _connect_to_achievement_system():
	# Try to get the achievement system from AchievementManager autoload first
	var achievement_manager = get_node_or_null("/root/AchievementManager")
	if achievement_manager and achievement_manager.has_method("get_achievement_system"):
		achievement_system = achievement_manager.get_achievement_system()
	
	# If not found, try direct access
	if achievement_system == null:
		achievement_system = get_node_or_null("/root/AchievementSystemNode")
	
	# If still not found, try again after a delay
	if achievement_system == null:
		print("Achievement UI: Achievement system not found, trying again in 0.5 seconds")
		await get_tree().create_timer(0.5).timeout
		_connect_to_achievement_system()
		return
	
	print("Achievement UI: Successfully connected to achievement system")
	achievement_system.connect("achievement_updated", Callable(self, "_on_achievement_updated"))
	
	# DEBUG: Print the current achievements
	if achievement_system.has_method("print_achievements"):
		achievement_system.print_achievements()
	
	_populate_achievements()

# Populate the achievements list
func _populate_achievements():
	print("Achievement UI: Populating achievements panel")
	
	# Clear existing achievements
	if achievement_container:
		for child in achievement_container.get_children():
			child.queue_free()
	else:
		print("Achievement UI: Error - achievement_container is null")
		return
	
	# Make sure achievement system is available
	if achievement_system == null:
		print("Achievement UI: Cannot populate achievements: achievement system not found")
		return
	
	# Add achievement items for each fish type
	var achievements = achievement_system.get_all_achievements()
	print("Achievement UI: Got achievements: ", achievements.keys().size(), " fish types")
	
	# Sort fish IDs numerically
	var sorted_ids = achievements.keys()
	sorted_ids.sort()
	
	for fish_type_id in sorted_ids:
		var achievement_data = achievements[fish_type_id]
		print("Achievement UI: Processing fish ID: ", fish_type_id, ", data: ", achievement_data)
		
		var item = achievement_item_scene.instantiate()
		achievement_container.add_child(item)
		
		# Configure the achievement item
		if achievement_data["caught"]:
			# Get fish name from ID
			var fish_name = achievement_system.get_fish_name(fish_type_id)
			print("Achievement UI: Setting fish name to: ", fish_name)
			item.set_fish_name(fish_name)
			
			# Set the fish-specific icon
			if FishesConfig.fishConfigMap.has(fish_type_id):
				var fish_config = FishesConfig.fishConfigMap[fish_type_id]
				item.set_icon(fish_config.icon)
		else:
			print("Achievement UI: Setting fish name to: ???")
			item.set_fish_name("???")
			item.set_icon(questionmark)
		
		# Add star icon if fish was caught as shiny
		if achievement_data["caught"] and achievement_data["shiny"]:
			print("Achievement UI: Adding shiny star for fish ID: ", fish_type_id)
			item.add_badge(star)
		
		# Add air bubble icon if fish was brought to surface
		if achievement_data["caught"] and achievement_data["surface"]:
			print("Achievement UI: Adding surface bubble for fish ID: ", fish_type_id)
			item.add_badge(air_bubble)

# Called when an achievement is updated
func _on_achievement_updated(fish_type_id, achievement_type):
	print("Achievement UI: Achievement updated - fish ID: ", fish_type_id, ", type: ", achievement_type)
	_populate_achievements()
