extends Node3D

@onready var muzzle = $Muzzle # Adjust path to your muzzle node
var bullet_scene = preload("res://scenes/bullet.tscn") # Path to your bullet scene
var ak_scene = preload("res://scenes/ak47.tscn") # Path to your bullet scene
var fire_rate = 0.1 # Seconds between shots (600 RPM for AK-47)
var can_shoot_ak = true

var can_show_gun_popup = true
var popup_cooldown = 1.0 # 1 second cooldown

# Ammo and cooldown settings
const BASE_MAX_AMMO = 30
const DUAL_MAX_AMMO = 60
const RELOAD_COOLDOWN = 3.0 # 3 seconds reload time

# Static variables to share state between both AK47s
static var shared_ammo = BASE_MAX_AMMO
static var shared_is_reloading = false
static var was_dual_ak_enabled = false

func _ready():
	# Create reload timer
	var timer = Timer.new()
	timer.name = "ReloadTimer"
	timer.one_shot = true
	timer.wait_time = RELOAD_COOLDOWN
	add_child(timer)
	timer.timeout.connect(_on_reload_complete)
	
	# Initialize shared state with appropriate ammo capacity
	shared_ammo = get_max_ammo()
	shared_is_reloading = false
	was_dual_ak_enabled = GameState.upgrades[GameState.Upgrade.DUALAK47]

func _process(_delta):
	# Check if dual AK47 was just enabled
	var is_dual_ak_enabled = GameState.upgrades[GameState.Upgrade.DUALAK47]
	if is_dual_ak_enabled != was_dual_ak_enabled:
		was_dual_ak_enabled = is_dual_ak_enabled
		if is_dual_ak_enabled:
			# Immediately update ammo to new capacity
			shared_ammo = DUAL_MAX_AMMO
			# Show upgrade message
			var pos = $PopupSpawnPosition.global_position
			PopupManager.show_popup("Dual AK47s Active - Ammo Capacity Increased!", pos, Color.GREEN)
	
	# Handle shooting
	if Input.is_action_pressed("shoot") and can_shoot_ak and !shared_is_reloading:
		if GameState.upgrades[GameState.Upgrade.AK47]:
			if shared_ammo > 0:
				shoot()
				can_shoot_ak = false
				await get_tree().create_timer(fire_rate).timeout
				can_shoot_ak = true
			elif !shared_is_reloading:
				start_reload()
		elif can_show_gun_popup:
			var pos = $PopupSpawnPosition.global_position
			PopupManager.show_popup("Buy Gun Upgrade to use gun", pos, Color.RED)
			can_show_gun_popup = false
			await get_tree().create_timer(popup_cooldown).timeout
			can_show_gun_popup = true

func get_max_ammo() -> int:
	return DUAL_MAX_AMMO if GameState.upgrades[GameState.Upgrade.DUALAK47] else BASE_MAX_AMMO

func shoot():
	# Instance a bullet
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	shared_ammo -= 1
	
	if shared_ammo <= 0 and !shared_is_reloading:
		start_reload()

func start_reload():
	if shared_is_reloading:
		return
		
	shared_is_reloading = true
	$ReloadTimer.start()
	# Show reload message
	var pos = $PopupSpawnPosition.global_position
	PopupManager.show_popup("Reloading...", pos, Color.YELLOW)

func _on_reload_complete():
	shared_ammo = get_max_ammo()
	shared_is_reloading = false
	# Show reload complete message
	var pos = $PopupSpawnPosition.global_position
	PopupManager.show_popup("Reload complete!", pos, Color.GREEN)

# Function to get reload progress (0 to 1)
func get_reload_progress() -> float:
	if !shared_is_reloading:
		return 1.0
	return 1.0 - ($ReloadTimer.time_left / RELOAD_COOLDOWN)

# Getter functions for shared state
func get_current_ammo() -> int:
	return shared_ammo

func is_currently_reloading() -> bool:
	return shared_is_reloading
