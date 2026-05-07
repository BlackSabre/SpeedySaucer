extends CharacterBody2D

@export var move_speed: float = 750
@export var turn_speed: float = 1.5
@export var max_turn_radians: float = 5
@export var attack_speed: float = 550

@export var angle_slerp_switch: float  = 0.35
@export var continuous_slerp_rate: float = 1.4
@export var distance_squared_abort_attack_threshold: int = 200000
@export var distance_squared_abort_turn_threshold: int = 450000
@export var distance_squared_start_turn_threshold: int = 900000
@export var acceleration_factor: float = 0.1

@onready var forward_raycast: RayCast2D = $Raycasts/Forward

var current_speed: float
var target_position: Vector2 = Vector2(0,0)
var current_direction: Vector2 = Vector2(1,0)
var desired_direction: Vector2 = Vector2(1,0)
var target_direction: Vector2 = Vector2(1,0)
var target_player: RigidBody2D
var current_state : EnemyState
var projectile_scene: PackedScene = preload("uid://mvh0g7obdpyp")
var first_raycast_collison: Object

enum EnemyState {
	CREATE_DISTANCE,
	ATTACK_RUN,
	TURNING
}


func _ready() -> void:
	current_speed = move_speed
	target_player = get_tree().get_first_node_in_group("Players")
	current_state = EnemyState.CREATE_DISTANCE
	get_tree().create_timer(2).timeout.connect(func(): current_state = EnemyState.TURNING)


func _physics_process(delta: float) -> void:	
	set_first_raycast_collider()

	if first_raycast_collison && first_raycast_collison.is_in_group("Players"):
		current_state = EnemyState.ATTACK_RUN

	match current_state:
		EnemyState.TURNING:
			turn_state(delta)
		EnemyState.ATTACK_RUN:
			attack_run_state(delta)
		EnemyState.CREATE_DISTANCE:
			create_distance_state()
	
	print(EnemyState.find_key(current_state))
	current_direction = calculate_collision_steering_vector2()
	rotation = rotate_toward(rotation, current_direction.angle(), max_turn_radians * delta)
	velocity = current_direction * current_speed
	
	move_and_slide()
		


func turn_state(delta):
	current_speed = clampf(current_speed, current_speed * -acceleration_factor, move_speed)
	var direction_to_player: Vector2 = (target_player.global_position - global_position).normalized()
	var angle_to_player: float = transform.x.angle_to(direction_to_player)
	var slerp_weight: float

	if angle_to_player < angle_slerp_switch:
		slerp_weight = continuous_slerp_rate * delta
	else: 
		slerp_weight = 1 - exp(-turn_speed * delta)

	#current_direction = current_direction.slerp(direction_to_player, slerp_weight)
	#current_direction = calculate_collision_steering_vector2()
	current_direction = current_direction.slerp(direction_to_player, slerp_weight)
	#rotation = rotate_toward(rotation, current_direction.angle(), max_turn_radians * delta)
	
	var distance_to_player_squared: float = global_position.distance_squared_to(target_player.global_position)

	if distance_to_player_squared < distance_squared_abort_turn_threshold:
		current_state = EnemyState.CREATE_DISTANCE


func create_distance_state():
	current_speed = clampf(current_speed, current_speed * -acceleration_factor, move_speed)
	var distance_to_player_squared: float = global_position.distance_squared_to(target_player.global_position)

	if distance_to_player_squared > distance_squared_start_turn_threshold:
		current_state = EnemyState.TURNING


func attack_run_state(_delta: float):
	current_speed = clampf(current_speed, current_speed * acceleration_factor, attack_speed)

	set_first_raycast_collider()
	if first_raycast_collison && first_raycast_collison.is_in_group("Players"):
		fire()

	var distance_to_player_squared: float = global_position.distance_squared_to(target_player.global_position)    
	
	if (distance_to_player_squared < distance_squared_abort_attack_threshold || 
		forward_raycast.is_colliding() == false):
		current_state = EnemyState.CREATE_DISTANCE


func set_first_raycast_collider():
	first_raycast_collison = forward_raycast.get_collider()


func fire():
	GlobalSignals.weapon_fired.emit(target_player.global_position, global_position, Enums.ProjectileSource.ENEMY)


func calculate_collision_steering_vector2() -> Vector2:
	var ray_length = 600
	var number_of_raycasts: int = 5
	var raycast_direction_offset = deg_to_rad(55)
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var avoidance_vector = Vector2.ZERO
	
	var start_index = -floor(float(number_of_raycasts) / 2.0)
	for i in range(number_of_raycasts):
		var direction = current_direction.rotated((start_index + i) * raycast_direction_offset)
		var query = PhysicsRayQueryParameters2D.create(
			global_position,
			global_position + direction * ray_length,
			collision_mask
		)
		var result = space_state.intersect_ray(query)
		if result:
			avoidance_vector += result.normal
	
	if avoidance_vector == Vector2.ZERO:
		return current_direction
	
	return (current_direction + avoidance_vector).normalized()
