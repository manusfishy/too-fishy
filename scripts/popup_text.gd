extends Label3D

@export var move_amount: float = 0.9
@export var duration: float = 1.0

func _ready():
	# Hide until started
	modulate.a = 0.0

func start_animation(text_to_show: String, color: Color, start_position: Vector3):
	
	text = text_to_show
	modulate = color
	global_position = start_position
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	
	# move up
	var target_position = global_position + Vector3(0, move_amount, 0)
	tween.tween_property(self, "global_position", target_position, duration)
	# fade out
	tween.chain().tween_interval(duration * 0.4)
	tween.tween_property(self, "modulate:a", 0.0, duration * 0.6).set_delay(duration * 0.4)
	
	tween.tween_callback(queue_free)
