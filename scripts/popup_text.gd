extends Label3D

@export var move_amount: float = 1.2
@export var duration: float = 0.8
@export var horizontal_drift: float = 0.15

func _ready():
	# Hide until started
	modulate.a = 0.0
	
	# Remove any background - we want sleek text only
	outline_modulate.a = 0.5

func start_animation(text_to_show: String, color: Color, start_position: Vector3, delay: float = 0.0):
	# Set initial state
	modulate = Color(color.r, color.g, color.b, 0.0)
	outline_modulate = Color(0.05, 0.08, 0.12, 0.0) # Dark outline with 0 alpha initially
	
	# Add subtle randomization to make each popup unique
	var offset_pop = Vector3(randf_range(-horizontal_drift, horizontal_drift), 0, 0)
	var final_start_position = start_position + offset_pop
	
	# Set the text and position
	text = text_to_show
	global_position = final_start_position
	
	# Calculate target position
	var target_position = final_start_position + Vector3(0, move_amount, 0)
	
	# Create tween for smooth animation
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	
	# Add delay if requested
	if delay > 0.0:
		tween.tween_interval(delay)
	
	# Create colors for animation
	var full_color = Color(color.r, color.g, color.b, 1.0)
	var full_outline = Color(0.05, 0.08, 0.12, 0.5) # Subtle dark outline
	var fade_out_color = Color(color.r, color.g, color.b, 0.0)
	var fade_out_outline = Color(0.05, 0.08, 0.12, 0.0)
	
	# Phase 1: Fade in with slight scale up for emphasis
	tween.tween_property(self, "modulate", full_color, 0.2)
	tween.parallel().tween_property(self, "outline_modulate", full_outline, 0.2)
	tween.parallel().tween_property(self, "scale", Vector3(1.1, 1.1, 1.1), 0.2)
	
	# Phase 2: Scale back to normal
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.15)
	
	# Phase 3: Move upward
	tween.parallel().tween_property(self, "global_position", target_position, duration - 0.15)
	
	# Phase 4: Fade out 
	var fade_start_proportion = 0.6 # Start fade after 60% of the movement
	var fade_start_time = (duration - 0.15) * fade_start_proportion
	var fade_duration = (duration - 0.15) - fade_start_time
	
	tween.parallel().tween_property(self, "modulate", fade_out_color, fade_duration).set_delay(fade_start_time)
	tween.parallel().tween_property(self, "outline_modulate", fade_out_outline, fade_duration).set_delay(fade_start_time)
	
	# Clean up
	tween.tween_callback(queue_free)
