extends StaticBody3D

var swing_active = false
var back_swing_active = false
@export var collision_detected = false
var schwing_geschwindigkeit = 5.0
var swing_duration = 0.4
var swing_time = 5.0
@onready var hand = get_parent()
@onready var player = hand.get_parent()
@onready var particles = null

func _ready():
	# Grundeinstellungen für die Pickaxe
	collision_layer = 0  # Keine Kollision für den StaticBody
	collision_mask = 0   # Keine Kollision mit anderen Objekten
	
	
	# Hitbox konfigurieren
	$PickaxeHitbox.collision_layer = 0
	$PickaxeHitbox.collision_mask = 3
	
	# Signal verbinden
	$PickaxeHitbox.body_entered.connect(_on_hitbox_body_entered)
	
	
	print("Pickaxe mit Hitbox initialisiert")
	
	# Partikel einrichten
	if not has_node("GPUParticles3D"):
		var particle_node = GPUParticles3D.new()
		particle_node.name = "GPUParticles3D"
		particles = particle_node
		particles.emitting = false
		particles.one_shot = true
		particles.explosiveness = 0.8
		particles.amount = 16
		particles.lifetime = 0.5
		add_child(particles)

func _process(delta):
	if Input.is_action_just_pressed("swing_pickaxe") and not swing_active and not back_swing_active:
		swing_active = true
		swing_time = 0.0
		print("Schwung begonnen")

	if swing_active:
		swing_time += delta
		var progress = swing_time / swing_duration
		var eased_progress = ease_in_out(progress)
		rotate_z(-schwing_geschwindigkeit * eased_progress * delta)

		if progress >= 1.0 or collision_detected:
			swing_active = false
			back_swing_active = true
			collision_detected = false
			swing_time = 0.0
			print("Schwung beendet")

	if back_swing_active:
		swing_time += delta
		var progress = swing_time / swing_duration
		var eased_progress = ease_in_out(1.0 - progress)
		rotate_z(schwing_geschwindigkeit * eased_progress * delta)

		if progress >= 1.0:
			rotation_degrees.z = 0
			back_swing_active = false

func ease_in_out(t):
	return t * t * (3.0 - 2.0 * t)

func _on_hitbox_body_entered(body):
	if not swing_active:
		return
		
	print("Pickaxe trifft:", body.name)
	
	if body.has_method("take_damage"):
		print("Schaden wird angewendet!")
		body.take_damage(1)
		collision_detected = true

func is_pickaxe() -> bool:
	return true
