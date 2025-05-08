extends StaticBody3D

class_name DestroyableBarrier

@export var max_health: int = 10
@export var current_health: int = 10

var hint_shown = false # Track if we've shown the hint already
var hint_cooldown = 3.0 # Cooldown between showing hints
var pickaxe_icon_material = null
var cracks_texture = null

func _ready():
	# Diese Einstellungen aus der TSCN-Datei verwenden
	collision_layer = 3 # Schon in der TSCN gesetzt
	collision_mask = 3 # Schon in der TSCN gesetzt
	add_to_group("abbaubare_objekte")
	print("DestroyableBarrier bereit - Health:", current_health)
	
	# Add area detection for player proximity
	var area = Area3D.new()
	area.name = "PlayerDetectionArea"
	
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(8, 8, 5) # Adjust size as needed
	collision_shape.shape = shape
	
	area.add_child(collision_shape)
	add_child(area)
	
	# Set up collision layers for player detection
	area.collision_layer = 0
	area.collision_mask = 1 # Layer for player
	
	# Connect signals
	area.body_entered.connect(_on_player_detection_area_body_entered)
	
	# Add visual indicator for pickaxe breakability
	add_pickaxe_indicator()

func add_pickaxe_indicator():
	# Create a small pickaxe icon or cracks indicator on the crate
	var indicator = MeshInstance3D.new()
	indicator.name = "PickaxeIndicator"
	
	# Create a quad mesh for the indicator
	var quad = QuadMesh.new()
	quad.size = Vector2(0.5, 0.5)
	indicator.mesh = quad
	
	# Position it on the front of the box
	indicator.position = Vector3(0, 0.5, -1.5)
	
	# Create a standard material with a custom texture or color
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0.8, 0, 1) # Gold/yellow color
	
	# Add a metallic effect to make it look like a tool
	material.metallic = 0.8
	material.roughness = 0.2
	
	# Make it billboard to always face the camera
	material.billboard_mode = StandardMaterial3D.BILLBOARD_FIXED_Y
	
	# Add emission to make it stand out
	material.emission_enabled = true
	material.emission = Color(0.8, 0.6, 0, 1)
	material.emission_energy_multiplier = 0.5
	
	indicator.material_override = material
	
	add_child(indicator)
	
	# Make it slowly rotate to catch attention
	var tween = create_tween()
	tween.tween_property(indicator, "rotation_degrees:y", 360, 3)
	tween.set_loops()
	
	# Add crack decals to the box
	add_crack_decals()

func add_crack_decals():
	# Create random cracks on the box surface
	var decal = Decal.new()
	decal.name = "CrackDecal"
	
	# Set size to cover the box
	decal.size = Vector3(2, 2, 2)
	
	# Create material - DECALS DON'T USE material_override, they use texture
	# Using a decal for cracks might not work easily, so we'll skip setting material
	# and let it use default
	
	add_child(decal)

func _on_player_detection_area_body_entered(body):
	# Check if it's the player
	if body.is_in_group("player") and !hint_shown:
		show_hint()
		
		# Set hint as shown and start cooldown
		hint_shown = true
		await get_tree().create_timer(hint_cooldown).timeout
		hint_shown = false

func show_hint():
	# Get the Popup_Manager to show the hint
	var popup_manager = get_node_or_null("/root/PopupManager")
	
	if popup_manager:
		# Check if player has pickaxe
		var has_pickaxe = GameState.upgrades[GameState.Upgrade.PICKAXE_UNLOCKED] == 1
		
		var message
		if has_pickaxe:
			message = "Use your pickaxe (SPACE) to break these blocks and progress!"
		else:
			message = "These blocks are blocking your path deeper! You'll need a pickaxe..."
		
		# Create a special popup instance with longer duration
		var popup_instance = load("res://scenes/popup_text.tscn").instantiate()
		get_tree().current_scene.add_child(popup_instance)
		popup_instance.global_position = global_position + Vector3(0, 1, 0)
		
		# Set a much longer duration (4 seconds instead of default 0.6)
		popup_instance.duration = 4.0
		
		# Make text larger for better visibility
		popup_instance.font_size = 42
		
		# Let start_animation handle the positioning completely
		var hint_position = global_position + Vector3(0, 1, 0)
		popup_instance.start_animation(message, Color.YELLOW, hint_position, 0.0)
	else:
		print("Popup manager not found!")

func take_damage(amount: int):
	current_health -= amount
	print("Schaden genommen! Verbleibende Gesundheit:", current_health)
	create_hit_particles()
	
	# Update crack appearance based on health
	update_crack_appearance()
	
	if current_health <= 0:
		destroy()

func update_crack_appearance():
	# Make cracks more visible as health decreases
	var crack_decal = get_node_or_null("CrackDecal")
	if crack_decal:
		# Decals don't have material_override, so we'll just scale it based on damage
		var health_percentage = float(current_health) / float(max_health)
		
		# Make decal larger as damage increases
		var scale_factor = 1.0 + (1.0 - health_percentage) * 0.5
		crack_decal.size = Vector3(2, 2, 2) * scale_factor

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
