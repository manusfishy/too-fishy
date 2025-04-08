extends StaticBody3D

class_name DestroyableBarrier

@export var max_health: int = 10
@export var current_health: int = 10

func _ready():
	# Diese Einstellungen aus der TSCN-Datei verwenden
	collision_layer = 3  # Schon in der TSCN gesetzt
	collision_mask = 3   # Schon in der TSCN gesetzt
	add_to_group("abbaubare_objekte")
	print("DestroyableBarrier bereit - Health:", current_health)

func take_damage(amount: int):
	current_health -= amount
	print("Schaden genommen! Verbleibende Gesundheit:", current_health)
	create_hit_particles()
	if current_health <= 0:
		destroy()

func destroy():
	create_destruction_particles()
	await get_tree().create_timer(0.5).timeout
	queue_free()
	
func create_hit_particles():
	var particles = GPUParticles3D.new()

	# Partikelmaterial konfigurieren
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.2
	material.gravity = Vector3(0, -1, 0)
	material.initial_velocity_min = 1.0
	material.initial_velocity_max = 3.0
	particles.process_material = material

	# Partikelform
	var mesh = SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.1
	particles.draw_pass_1 = mesh

	particles.one_shot = true
	particles.emitting = true
	particles.amount = 10
	particles.lifetime = 0.5

	get_parent().add_child(particles)
	particles.global_position = global_position

	# Partikel nach Ablauf löschen
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(particles):
		particles.queue_free()


func create_destruction_particles():
	var particles = GPUParticles3D.new()

	# Partikelmaterial konfigurieren
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.5
	material.gravity = Vector3(0, -2, 0)
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 5.0
	particles.process_material = material

	# Partikelform
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.1, 0.1, 0.1)
	particles.draw_pass_1 = mesh

	particles.one_shot = true
	particles.emitting = true
	particles.amount = 30
	particles.lifetime = 1.0

	get_parent().add_child(particles)
	particles.global_position = global_position

	# Partikel nach Ablauf löschen
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(particles):
		particles.queue_free()
