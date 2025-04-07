extends CharacterBody3D

@export var player: Node3D
@export var charge_speed: float = 15.0
@export var charge_duration: float = 1.0
@export var cooldown_duration: float = 1.5
@export var damage_amount: int = 30

enum BossStates {COOLDOWN, CHARGING, PREPARING}
var state = BossStates.PREPARING
var timer = 0.0
var charge_direction = Vector3.ZERO
var has_hit_player = false

func _physics_process(delta):
	if player == null:
		return
		
	match state:
		BossStates.PREPARING:
			has_hit_player = false
		
			charge_direction = (player.global_position - global_position).normalized()
			charge_direction.z = 0
			state = BossStates.CHARGING
			timer = charge_duration
			
		BossStates.CHARGING:
			velocity = charge_direction * charge_speed
			var collision = move_and_slide()
			
			check_player_collision()
			
			timer -= delta
			if timer <= 0:
				state = BossStates.COOLDOWN
				timer = cooldown_duration
				velocity = Vector3.ZERO
		
		BossStates.COOLDOWN:
			timer -= delta
			if timer <= 0:
				state = BossStates.PREPARING
	position.z = -0.33

func check_player_collision():
	if has_hit_player:
		return
		
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider == player:
			on_player_collision()
			has_hit_player = true
			break
		
func on_player_collision():
	print("Boss hit the player!")
	
	GameState.health -= damage_amount
