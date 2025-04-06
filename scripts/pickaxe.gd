extends StaticBody3D
var swing_active = false
var back_swing_active = false
@export var collision_detected = false
var schwing_geschwindigkeit = 5.0
var swing_duration = 0.4
var swing_time = 5.0
@onready var hand = get_parent()
@onready var player = hand.get_parent()
@onready var particles = null # $GPUParticles3D

func _ready():
	position = Vector3(0, 0, 0)
	#freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	#gravity_scale = 0
	if not has_node("GPUParticles3D"):
		var particle_node = GPUParticles3D.new()
		particle_node.name = "GPUParticles3D"
		particles = particle_node
		particles.emitting = false
		particles.one_shot = true
		particles.explosiveness = 0.8
		particles.amount = 16
		particles.lifetime = 0.5

func _process(delta):
	if Input.is_action_just_pressed("swing_pickaxe") and not swing_active and not back_swing_active:
		swing_active = true
		swing_time = 0.0

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
	
func _on_body_entered(body):
	if body.is_in_group("abbaubare_objekte"):
		print("Kollision mit: ", body.name)
	if body.has_method("take_damage"):
		body.take_damage(1) # Schadenswert anpassen
		collision_detected = true
