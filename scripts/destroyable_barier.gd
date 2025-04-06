extends StaticBody3D

class_name DestroyableBarrier

@export var max_health: int = 10
@export var current_health: int = 10

var colliding_bodies = []
var can_take_damage = true

func _ready():
	collision_layer = 2
	collision_mask = 1

	var area = Area3D.new()
	area.name = "CollisionDetector"
	add_child(area)

	if not has_node("CollisionShape3D"):
		var shape = CollisionShape3D.new()
		shape.shape = BoxShape3D.new()
		area.add_child(shape.duplicate())
	else:
		area.add_child($CollisionShape3D.duplicate())

	area.collision_layer = 1
	area.collision_mask = 2 
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)



func _on_body_entered(body):
	print("Körper betritt Area:", body.name)
	colliding_bodies.append(body)

func _on_body_exited(body):
	print("Körper verlässt Area:", body.name)
	colliding_bodies.erase(body)
	if body.has_method("is_pickaxe"):
				if body.is_pickaxe():
					take_damage(1)
					can_take_damage = false
					

func take_damage(amount: int):
	current_health -= amount
	print("barier took damage helth left:", current_health)

	create_hit_particles()

	if current_health <= 0:
		destroy()

func destroy():
	print("Barrier is destroyed")
	create_destruction_particles()

	await get_tree().create_timer(0.5).timeout
	queue_free()

func create_hit_particles():
	var particles = GPUParticles3D.new()


	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.2
	material.gravity = Vector3(0, -1, 0)
	material.initial_velocity_min = 1.0
	material.initial_velocity_max = 3.0
	particles.process_material = material

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
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(particles):
		particles.queue_free()

func create_destruction_particles():
	var particles = GPUParticles3D.new()
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.5
	material.gravity = Vector3(0, -2, 0)
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 5.0
	particles.process_material = material

	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.1, 0.1, 0.1)
	particles.draw_pass_1 = mesh

	particles.one_shot = true
	particles.emitting = true
	particles.amount = 30
	particles.lifetime = 1.0

	get_parent().add_child(particles)
	particles.global_position = global_position
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(particles):
		particles.queue_free()
