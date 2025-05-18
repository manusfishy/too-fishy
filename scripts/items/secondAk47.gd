extends Node3D

@onready var muzzle = $Muzzle # Adjust path to your muzzle node
var bullet_scene = preload("res://scenes/bullet.tscn") # Path to your bullet scene
var ak_scene = preload("res://scenes/ak47.tscn") # Path to your bullet scene
var fire_rate = 0.1 # Seconds between shots (600 RPM for AK-47)
var can_shoot_ak = true

# Reference to main AK47
var main_ak47 = null

func _ready():
	# Find the main AK47 in the scene
	var submarine = get_node("../../..")
	if submarine and submarine.has_node("Pivot/SmFishSubmarine/ak47_0406195124_texture"):
		main_ak47 = submarine.get_node("Pivot/SmFishSubmarine/ak47_0406195124_texture")

func _process(_delta):
	if !main_ak47:
		return
		
	if Input.is_action_pressed("shoot") and can_shoot_ak and !main_ak47.shared_is_reloading and GameState.upgrades[GameState.Upgrade.DUALAK47]:
		if main_ak47.shared_ammo > 0:
			shoot()
			can_shoot_ak = false
			await get_tree().create_timer(fire_rate).timeout
			can_shoot_ak = true

func shoot():
	if !main_ak47:
		return
		
	# Instance a bullet
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	
	# Decrement shared ammo
	main_ak47.shared_ammo -= 1
	
	# Start reload if out of ammo
	if main_ak47.shared_ammo <= 0 and !main_ak47.shared_is_reloading:
		main_ak47.start_reload()
