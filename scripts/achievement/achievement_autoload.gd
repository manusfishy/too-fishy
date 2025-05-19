extends Node

# Reference to the achievement system
var achievement_system

func _ready():
	print("Achievement Manager: Initializing...")
	
	# Create the achievement system immediately
	_initialize_achievement_system()
	
	# Connect to game state with a small delay to ensure all nodes are ready
	call_deferred("_connect_achievement_system")

func _initialize_achievement_system():
	# Create the achievement system
	achievement_system = AchievementSystem.new()
	achievement_system.name = "AchievementSystemNode"
	
	# Add to the root node to make it globally accessible
	add_child(achievement_system)
	print("Achievement Manager: System initialized")

func _connect_achievement_system():
	# Connect to GameState
	await get_tree().process_frame
	if GameState:
		achievement_system.connect_to_gamestate(GameState)
		print("Achievement Manager: Connected to GameState")
	else:
		print("Achievement Manager: GameState not found, trying again")
		await get_tree().create_timer(0.5).timeout
		_connect_achievement_system()
		return
	
	# Connect achievement system to player
	_connect_to_player()

func _connect_to_player():
	# Wait for player node to be ready
	await get_tree().process_frame
	
	if GameState.player_node and GameState.player_node.has_method("connect_achievement_system"):
		GameState.player_node.connect_achievement_system(achievement_system)
		print("Achievement Manager: Connected to player")
	else:
		# Retry after a delay if player not ready
		print("Achievement Manager: Player not ready, trying again")
		await get_tree().create_timer(0.5).timeout
		_connect_to_player()

# Method to access the achievement system from other scripts
func get_achievement_system() -> AchievementSystem:
	return achievement_system