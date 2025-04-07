extends Node3D

@onready var muzzle = $Muzzle # Adjust path to your muzzle node
var bullet_scene = preload("res://scenes/bullet.tscn") # Path to your bullet scene
var ak_scene = preload("res://scenes/ak47.tscn") # Path to your bullet scene
var fire_rate = 0.1 # Seconds between shots (600 RPM for AK-47)
var can_shoot_ak = true

func _process(delta):
	if Input.is_action_pressed("shoot") and can_shoot_ak and GameState.upgrades[GameState.Upgrade.DUALAK47]:
			shoot()
			can_shoot_ak = false
			await get_tree().create_timer(fire_rate).timeout
			can_shoot_ak = true

func shoot():
	# Instance a bullet
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
