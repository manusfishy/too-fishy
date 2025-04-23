extends CanvasLayer

# Damage visual effects controller
# Handles screen crack and red flash effects when player takes damage

@onready var screen_crack = $ScreenCrack
@onready var red_flash = $RedFlash

# Tween for animations
var tween
var flash_duration = 0.5  # Duration of red flash in seconds
var crack_fade_time = 2.0  # Time for crack to fade out

func _ready():
	# Initialize with invisible effects
	screen_crack.modulate.a = 0
	red_flash.modulate.a = 0

# Show damage effects when player takes damage
func show_damage_effects():
	# Cancel any existing tween
	if tween:
		tween.kill()
	
	# Create new tween
	tween = create_tween()
	
	# Red flash effect - quick flash that fades out
	red_flash.modulate.a = 0.7  # Start with high opacity
	tween.parallel().tween_property(red_flash, "modulate:a", 0.0, flash_duration)  # Fade out quickly
	
	# Screen crack effect - appears and slowly fades out
	screen_crack.modulate.a = 0.9  # Start with high opacity
	tween.parallel().tween_property(screen_crack, "modulate:a", 0.0, crack_fade_time)  # Fade out slowly
