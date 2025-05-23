extends Control

# Damage visual effects controller
# Handles screen crack and red flash effects when player takes damage

@onready var red_flash = $RedFlash

var flash_duration = 0.5 # Duration of red flash in seconds
var crack_fade_time = 3.0 # Time for crack to fade out
var max_cracks = 5 # Maximum number of crack layers
var current_crack_count = 0
var crack_sprites = []

func _ready():
	# Initialize with invisible effects
	red_flash.modulate.a = 0
	red_flash.color = Color(1, 0, 0, 0) # Pure red, fully transparent initially
	print("Damage effects initialized")

# Called when player takes damage
func show_damage_effects():
	print("Showing damage effects - red flash and adding crack layer")
	print("Current crack count before: ", current_crack_count, "/", max_cracks)
	
	# Show red flash - make it more visible
	red_flash.modulate.a = 1.0 # Fully opaque
	red_flash.color = Color(1, 0, 0, 0.6) # Semi-transparent red
	var flash_tween = create_tween()
	flash_tween.tween_property(red_flash, "color:a", 0.0, flash_duration)
	
	# Add a new crack layer if we haven't reached the maximum
	if current_crack_count < max_cracks:
		add_crack_layer()
	else:
		print("Max cracks reached, not adding more")

func add_crack_layer():
	print("Adding crack layer...")
	current_crack_count += 1
	
	# Create a new crack sprite
	var crack_sprite = TextureRect.new()
	crack_sprite.name = "CrackLayer" + str(current_crack_count)
	
	# Load the texture and check if it loaded successfully
	var crack_texture = load("res://textures/effects/screen_crack.png")
	if crack_texture == null:
		print("ERROR: Could not load crack texture!")
		return
	
	crack_sprite.texture = crack_texture
	print("Crack texture loaded successfully")
	
	# Set up the crack sprite properties
	crack_sprite.layout_mode = 1
	crack_sprite.anchors_preset = 15 # Fill the screen
	crack_sprite.anchor_right = 1.0
	crack_sprite.anchor_bottom = 1.0
	crack_sprite.grow_horizontal = 2
	crack_sprite.grow_vertical = 2
	crack_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crack_sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	crack_sprite.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	
	# Make cracks more visible with different opacities
	var crack_alpha = 0.8 - (current_crack_count * 0.1) # Start at 0.8, decrease slightly
	crack_sprite.modulate = Color(1, 1, 1, crack_alpha)
	
	# Randomize the crack appearance
	crack_sprite.rotation = randf() * 2 * PI # Random rotation
	
	# Add to scene
	add_child(crack_sprite)
	crack_sprites.append(crack_sprite)
	
	print("Added crack layer ", current_crack_count, "/", max_cracks, " with alpha: ", crack_alpha)
	print("Total crack sprites: ", crack_sprites.size())
	
	# Fade out this crack over time (but make it slower so cracks accumulate)
	var crack_tween = create_tween()
	crack_tween.tween_interval(crack_fade_time) # Wait before starting to fade
	crack_tween.tween_property(crack_sprite, "modulate:a", 0, 1.0) # Then fade out over 1 second
	crack_tween.tween_callback(func(): remove_crack_layer(crack_sprite))

func remove_crack_layer(crack_sprite):
	if crack_sprite and is_instance_valid(crack_sprite):
		crack_sprites.erase(crack_sprite)
		crack_sprite.queue_free()
		current_crack_count = max(0, current_crack_count - 1)
		print("Removed crack layer, remaining: ", current_crack_count)

# Call this when player heals or resets
func clear_all_cracks():
	for crack in crack_sprites:
		if is_instance_valid(crack):
			crack.queue_free()
	crack_sprites.clear()
	current_crack_count = 0
	print("Cleared all crack layers")

# Test function - call this to manually test crack accumulation
func test_add_cracks():
	print("TEST: Adding multiple cracks for testing...")
	for i in range(3):
		show_damage_effects()
		await get_tree().create_timer(0.2).timeout # Small delay between cracks
