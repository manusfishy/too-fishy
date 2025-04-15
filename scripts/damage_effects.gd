extends Node2D

# Damage visual effects controller
# Handles screen crack and red flash effects when player takes damage

@onready var crack_texture = preload("res://textures/effects/screen_crack.png")
@onready var crack_sprite = $CrackSprite
@onready var red_flash = $RedFlash

var flash_duration = 0.3  # Duration of red flash in seconds
var crack_fade_time = 2.0  # Time for crack to fade out

func _ready():
	# Initialize with invisible effects
	crack_sprite.modulate.a = 0
	red_flash.modulate.a = 0

# Called when player takes damage
func show_damage_effects():
	# Show red flash
	red_flash.modulate.a = 0.5  # Semi-transparent red
	var flash_tween = create_tween()
	flash_tween.tween_property(red_flash, "modulate:a", 0, flash_duration)
	
	# Show crack effect
	crack_sprite.modulate.a = 1.0  # Fully visible
	var crack_tween = create_tween()
	crack_tween.tween_property(crack_sprite, "modulate:a", 0, crack_fade_time)
