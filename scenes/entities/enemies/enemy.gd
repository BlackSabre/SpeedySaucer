extends CharacterBody2D

@export var move_speed: float = 500
@export var turn_speed: float = 2
@export var max_turn_radians: float = 5
@export var attack_speed: float = 750

@export var angle_slerp_switch: float  = 0.55
@export var continuous_slerp_rate: float = 3.0
@export var abort_attack_distance_threshold: int = 1500
@export var abort_turn_distance_threshold: int = 900
@export var start_turn_distance_threshold: int = 800
@export var acceleration_factor: float = 50
#@onready var forward_raycast: RayCast2D = $Raycasts/Forward
@onready var avoidance_multiplier: float = 100.0
var forward_raycast: RayCast2D = null

var current_speed: float
var current_direction: Vector2 = Vector2(1,0)
var desired_direction: Vector2 = Vector2(1,0) # Direction to goal
var steered_direction: Vector2 = Vector2(1,0) # Direction with steering taken into account
var target_player: RigidBody2D
var current_state : EnemyState
var steering_slerp_weight: float = 0.2
var steering_timer: float
var steering_interval: float = 0.05
var distance_to_player: float
var avoidance_vector: Vector2
var previous_avoidance_vector: Vector2

# Raycast Info
var raycast_length: int = 800
@export var number_of_raycasts: int = 2
var s
var raycast_directions: Array[Vector2]
@export var degrees_between_raycasts: int = 10

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


func _physics_process(delta: float) -> void:	
	distance_to_player = position.distance_squared_to(target_player.global_position)
	
	if forward_raycast && forward_raycast.is_colliding() && forward_raycast.get_collider().is_in_group("Players"):
		current_state = EnemyState.ATTACK_RUN

	match current_state:
		EnemyState.TURNING:
			turn_state(delta)
		EnemyState.ATTACK_RUN:
			attack_run_state(delta)
		EnemyState.CREATE_DISTANCE:
			create_distance_state(delta)
	
	#print(EnemyState.find_key(current_state))
	apply_steering(delta)
	
	#print(steered_direction)
	#current_direction = current_direction.slerp(steered_direction, steering_slerp_weight)
	current_direction = Vector2(1.0, 1.0)
	rotation = rotate_toward(rotation, current_direction.angle(), max_turn_radians * delta)
	velocity = current_direction * current_speed
	
	move_and_slide()
	queue_redraw()
	collide_with_rigid_bodies()


func turn_state(delta):
	current_speed = move_toward(current_speed, move_speed, acceleration_factor * delta)
	var direction_to_player: Vector2 = (target_player.global_position - global_position).normalized()
	var angle_to_player: float = transform.x.angle_to(direction_to_player)	

	if abs(angle_to_player) < angle_slerp_switch && distance_to_player < 500000:
		steering_slerp_weight = continuous_slerp_rate * delta
	else: 
		steering_slerp_weight = 1 - exp(-turn_speed * delta)
	
	desired_direction = direction_to_player
	#steered_direction = direction_to_player # for debug
	var distance_to_player_squared: float = global_position.distance_squared_to(target_player.global_position)
	var abort_turn_distance_threshold_squared: float = abort_turn_distance_threshold * abort_turn_distance_threshold
	
	if distance_to_player_squared < abort_turn_distance_threshold_squared:
		current_state = EnemyState.CREATE_DISTANCE


func create_distance_state(delta: float):
	desired_direction = (global_position - target_player.global_position).normalized()
	#desired_direction = current_direction
	current_speed = move_toward(current_speed, move_speed, acceleration_factor * delta)
	steering_slerp_weight = 1 - exp(-turn_speed * delta)
	var distance_to_player_squared: float = global_position.distance_squared_to(target_player.global_position)

	if distance_to_player_squared > (start_turn_distance_threshold * start_turn_distance_threshold):
		current_state = EnemyState.TURNING


func attack_run_state(delta: float):
	desired_direction = (target_player.global_position - global_position).normalized()
	steering_slerp_weight = 1 - exp(-turn_speed * delta)
	current_speed = move_toward(current_speed, attack_speed, acceleration_factor * delta)
	
	if forward_raycast.is_colliding() && forward_raycast.get_collider().is_in_group("Players"):
		fire()

	var distance_to_player_squared: float = global_position.distance_squared_to(target_player.global_position)    
	
	if (distance_to_player_squared < (abort_attack_distance_threshold * abort_attack_distance_threshold) || 
		forward_raycast.is_colliding() == false):
		current_state = EnemyState.CREATE_DISTANCE


func fire():
	GlobalSignals.weapon_fired.emit(target_player.global_position, global_position, Enums.ProjectileSource.ENEMY)


func calculate_interest_map() -> Vector2:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var queries: Array[PhysicsRayQueryParameters2D]
	var raycast_target_vectors: Array[Vector2] = create_raycast_target_vectors(true)
	
	for target in raycast_target_vectors:		
		var query = PhysicsRayQueryParameters2D.create(
			global_position,
			target,
			self.collision_mask
		)
	
		query.exclude = [self]
		
		var result := space_state.intersect_ray(query)
		if result:
			print(result.collider.name)	
	
	return Vector2.ONE


func create_raycast_target_vectors(is_global_space: bool) -> Array[Vector2]:
	var raycast_target_vector_arr: Array[Vector2] = []
	var raycasts_per_side: int = floor(float(number_of_raycasts) / 2.0)	
	var normalized_direction: Vector2 = current_direction.normalized()
	var is_even = number_of_raycasts % 2 == 0
	var offset = 0.5 if is_even else 0.0
	
	for i in range(number_of_raycasts):
		var raycast_index: float = i - raycasts_per_side + offset
		var raycast_direction_offset = deg_to_rad(degrees_between_raycasts * raycast_index)
		var direction = normalized_direction.rotated(raycast_direction_offset) * raycast_length
		var to_point = global_position + direction
			
		if is_global_space:
			raycast_target_vector_arr.append(to_point)
		else:
			raycast_target_vector_arr.append(to_local(to_point))
	
	return raycast_target_vector_arr


func create_raycast_target_vectors_old(is_global_space: bool) -> Array[Vector2]:
	var raycast_target_vector_arr: Array[Vector2]
	var raycasts_per_side: int = floor(float(number_of_raycasts) / 2.0)
	var current_raycast_index = raycasts_per_side * -1
	
	while current_raycast_index <= raycasts_per_side:
		# Even numbers_of_raycasts will not have a raycast directly in front of them
		if (current_raycast_index == 0 && number_of_raycasts % 2 == 0):
			#pass
			current_raycast_index += 1
			continue
		
		var raycast_direction_offset = deg_to_rad(degrees_between_raycasts * current_raycast_index)
		var direction = current_direction.normalized().rotated(raycast_direction_offset) * raycast_length
		var to_point = global_position + direction;
			
		print(current_raycast_index)
		current_raycast_index += 1
	
		if is_global_space:
			raycast_target_vector_arr.append(to_point)
		else:
			raycast_target_vector_arr.append(to_local(to_point))
	
	return raycast_target_vector_arr;
	

func _draw():	
	var raycast_target_vectors := create_raycast_target_vectors(false)
	for target in raycast_target_vectors:
		draw_line(Vector2.ZERO, target, Color.GREEN, 5)


func calculate_collision_steering_vector2() -> Vector2:
	var ray_length = 700
	var number_of_raycasts: int = 3
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
		
		query.exclude = [self]
		var result := space_state.intersect_ray(query)
		if result: print(result.collider.name)
		if !result || result.collider.is_in_group("Players"):
			continue;
		
		var distance = max(global_position.distance_to(result.position), 40.0)
		var avoidance_weight = 1.0 - (distance / ray_length)
		avoidance_vector += result.normal * avoidance_weight * 1.2
		
	avoidance_vector = previous_avoidance_vector.lerp(avoidance_vector, 0.2)
	previous_avoidance_vector = avoidance_vector
	
	if avoidance_vector == Vector2.ZERO:
		return desired_direction
	
	return (avoidance_vector + desired_direction).normalized()


func apply_steering(delta: float):
	steering_timer += delta
	if steering_timer > steering_interval:
		steering_timer = 0.0
		#steered_direction = calculate_collision_steering_vector2()
		steered_direction = calculate_interest_map()


func collide_with_rigid_bodies():
	# apply rigid body collision calculations
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is RigidBody2D:
			var push_direction = -collision.get_normal()
			var push_force = 200.0
			collider.apply_central_impulse(push_direction * push_force)
