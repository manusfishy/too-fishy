extends Label3D

@export var move_amount: float = 0.9
@export var duration: float = 0.6
@export var horizontal_drift: float = 0.2

func _ready():
	# Hide until started
	modulate.a = 0.0

func start_animation(text_to_show: String, color: Color, start_position: Vector3, delay: float = 0.0):
	var initial_modulate = Color(color.r, color.g, color.b, 0.0)

	modulate = initial_modulate
	
	var offset = Vector3(randf_range(-horizontal_drift, horizontal_drift), 0, 0)
	var final_start_position = start_position + offset
	
	text = text_to_show
	
	var target_position = final_start_position + Vector3(0, move_amount, 0)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	
	if delay > 0.0:
		tween.tween_interval(delay)
	
	# Fade in while preserving color
	var full_color = Color(color.r, color.g, color.b, 1.0)
	tween.tween_property(self, "modulate", full_color, 0.3)
	
	var parallel_tween = tween.parallel()
	
	# move up
	tween.tween_property(self, "global_position", target_position, duration)
	
	# fade out - important: fade the whole color, not just alpha
	var fade_start_proportion = 0.666 # Start fade 2/3rds through the movement
	var fade_start_time = duration * fade_start_proportion
	var fade_duration = duration - fade_start_time
	
	# Create a fade-out color that maintains RGB values
	var fade_out_color = Color(color.r, color.g, color.b, 0.0)
	parallel_tween.tween_property(self, "modulate", fade_out_color, fade_duration).set_delay(fade_start_time)
	
	tween.tween_callback(queue_free)
