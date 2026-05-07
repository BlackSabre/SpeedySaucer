extends CharacterBody2D

@export var move_speed: float = 500
@export var turn_speed: float = 1.5
@export var max_turn_radians: float = 3
@export var attack_speed: float = 750

@export var angle_slerp_switch: float  = 0.55
@export var continuous_slerp_rate: float = 2.0
@export var distance_squared_abort_attack_threshold: int = 100000
@export var distance_squared_abort_turn_threshold: int = 450000
@export var distance_squared_start_turn_threshold: int = 900000
@export var acceleration_factor: float = 50

@onready var forward_raycast: RayCast2D = $Raycasts/Forward
@onready var avoidance_multiplier: float = 100.0

var current_speed: float
var current_direction: Vector2 = Vector2(1,0)
var desired_direction: Vector2 = Vector2(1,0) # Direction to goal
var steered_direction: Vector2 = Vector2(1,0) # Direction with steering taken into account
var target_player: RigidBody2D
var current_state : EnemyState
var steering_slerp_weight: float = 0.2
var steering_timer: float
var steering_interval: float = 0.1
var distance_to_player: float
var avoidance_vector: Vector2
var previous_avoidance_vector: Vector2

var degrees_between_raycasts: int = 60

enum EnemyState {
	CREATE_DISTANCE,
	ATTACK_RUN,
	TURNING
}


func _ready() -> void:
	current_speed = move_speed
	target_player = get_tree().get_first_node_in_group("Players")
	current_state = EnemyState.CREATE_DISTANCE
	desired_direction = (global_position - target_player.global_position).normalized()
	#previous_avoidance_vector = Vector2.LEFT


func _physics_process(delta: float) -> void:
	steering_timer += delta
	distance_to_player = position.distance_squared_to(target_player.global_position)
	
	if forward_raycast.is_colliding() && forward_raycast.get_collider().is_in_group("Players"):
		current_state = EnemyState.ATTACK_RUN

	match current_state:
		EnemyState.TURNING:
			turn_state(delta)
		EnemyState.ATTACK_RUN:
			attack_run_state(delta)
		EnemyState.CREATE_DISTANCE:
			create_distance_state(delta)
	
	if steering_timer > steering_interval:
		steering_timer = 0.0
		steered_direction = calculate_collision_steering_vector2()
	
	current_direction = current_direction.slerp(steered_direction, steering_slerp_weight)	
	rotation = rotate_toward(rotation, current_direction.angle(), max_turn_radians * delta)
	velocity = current_direction * current_speed
	
	move_and_slide()
		


func turn_state(delta):
	current_speed = move_toward(current_speed, move_speed, acceleration_factor * delta)
	var direction_to_player: Vector2 = (target_player.global_position - global_position).normalized()
	var angle_to_player: float = transform.x.angle_to(direction_to_player)	

	if angle_to_player < angle_slerp_switch && distance_to_player < 500000:
		steering_slerp_weight = continuous_slerp_rate * delta
	else: 
		steering_slerp_weight = 1 - exp(-turn_speed * delta)
	
	desired_direction = direction_to_player
	var distance_to_player_squared: float = global_position.distance_squared_to(target_player.global_position)

	if distance_to_player_squared < distance_squared_abort_turn_threshold:
		current_state = EnemyState.CREATE_DISTANCE


func create_distance_state(delta: float):
	desired_direction = (global_position - target_player.global_position).normalized()
	current_speed = move_toward(current_speed, move_speed, acceleration_factor * delta)
	steering_slerp_weight = 1 - exp(-turn_speed * delta)
	var distance_to_player_squared: float = global_position.distance_squared_to(target_player.global_position)

	if distance_to_player_squared > distance_squared_start_turn_threshold:
		current_state = EnemyState.TURNING


func attack_run_state(delta: float):
	desired_direction = (target_player.global_position - global_position).normalized()
	steering_slerp_weight = 1 - exp(-turn_speed * delta)
	current_speed = move_toward(current_speed, attack_speed, acceleration_factor * delta)
	
	if forward_raycast.is_colliding() && forward_raycast.get_collider().is_in_group("Players"):
		fire()

	var distance_to_player_squared: float = global_position.distance_squared_to(target_player.global_position)    
	
	if (distance_to_player_squared < distance_squared_abort_attack_threshold || 
		forward_raycast.is_colliding() == false):
		current_state = EnemyState.CREATE_DISTANCE


func fire():
	GlobalSignals.weapon_fired.emit(target_player.global_position, global_position, Enums.ProjectileSource.ENEMY)


func calculate_collision_steering_vector2() -> Vector2:
	var ray_length = 1200
	var number_of_raycasts: int = 7
	var raycast_direction_offset = deg_to_rad(degrees_between_raycasts)
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state	
	avoidance_vector = Vector2.ZERO
	
	var start_index = -floor(float(number_of_raycasts) / 2.0)
	for i in range(number_of_raycasts):
		var direction = current_direction.rotated((start_index + i) * raycast_direction_offset)
		var query = PhysicsRayQueryParameters2D.create(
			global_position,
			global_position + direction * ray_length,
			self.collision_mask
		)
		var result := space_state.intersect_ray(query)
		if result:
			var distance = max(global_position.distance_to(result.position), 20.0)
			var avoidance_weight = 1.0 - (distance / ray_length)
			avoidance_vector += result.normal * avoidance_weight * 2
			avoidance_vector = previous_avoidance_vector.lerp(avoidance_vector, 0.15)
			previous_avoidance_vector = avoidance_vector
	
	if avoidance_vector == Vector2.ZERO:
		return desired_direction
	
	return (avoidance_vector + desired_direction).normalized()
