extends CharacterBody2D

@export var move_speed: float = 300
@export var turn_rate: float = 1
@export var max_rotation_radians: float = 0.2
@export var attack_move_speed: float = 750
@export var accleration_factor: float = 50
@export var raycaster: Raycaster

var current_speed: float
var target_speed: float
var current_direction: Vector2 = Vector2(1, 0)

var target_player: RigidBody2D
var current_state: EnemyState

var steering_timer: float = 5.0
var patrol_timer: float = 0.0
var patrol_timer_max: float = 5.0
var normalized_previous_direction: Vector2

var target_global_positions: Array[Vector2]

enum EnemyState {
	CREATE_DISTANCE,
	ATTACK_RUN,
	TURNING
}


func _ready() -> void:
	current_speed = move_speed
	current_state = EnemyState.CREATE_DISTANCE
	target_player = get_tree().get_first_node_in_group("Players")
	current_direction = (target_player.global_position - global_position).normalized()
	normalized_previous_direction = current_direction
	target_global_positions.append(target_player.global_position)
	look_at(target_player.global_position)


func _physics_process(delta: float) -> void:
	target_global_positions = _find_next_target(delta)
	velocity = _calculate_velocity(delta)
	var angle = current_direction.angle()
	rotation = lerp_angle(rotation, angle, max_rotation_radians)
	move_and_slide()


# current_direction, normalized_previous_direction
func _calculate_velocity(delta: float) -> Vector2:
	var direction_lerp_weight: float = 1.0 - exp(-turn_rate * delta)
	var ray_result_data: Array[RayResult] = _calculate_ray_data()
	
	var weighted_goal_direction: Vector2 = _calculate_direction(ray_result_data)
	normalized_previous_direction = current_direction
	
	var lerped_direction: Vector2 = lerp(current_direction, weighted_goal_direction, direction_lerp_weight).normalized()
	if not lerped_direction.is_zero_approx():
		current_direction = lerped_direction
	
	return current_direction * move_speed


func _calculate_ray_data() -> Array[RayResult]:
	var ray_exclusion_rid_array: Array[RID] = [self.get_rid(), target_player.get_rid()]
	return raycaster.cast_rays_in_direction(current_direction, collision_mask, ray_exclusion_rid_array)


func _calculate_direction(ray_result_data: Array[RayResult]) -> Vector2:
	var steering_manager_settings = SteeringManagerSettings.new()
	
	steering_manager_settings.source_global_position = global_position
	steering_manager_settings.target_global_positions = target_global_positions
	steering_manager_settings.normalized_previous_direction = normalized_previous_direction
	steering_manager_settings.normalized_current_direction = current_direction.normalized()
	steering_manager_settings.ray_results = ray_result_data
	steering_manager_settings.ray_length = raycaster.ray_length
	
	return SteeringManager.calculate_direction(steering_manager_settings)


# Returns the player global position if ahead of the enemy, otherwise returns a random
# global_position. Does not currently support having multiple targets
func _find_next_target(delta: float) -> Array[Vector2]:
	patrol_timer += delta
	
	var direction_to_player = (target_player.global_position - global_position).normalized()
	var enemy_player_alignment: float = current_direction.dot(direction_to_player)
	if enemy_player_alignment > 0:
		target_global_positions.clear()
		target_global_positions.append(target_player.global_position)
		return target_global_positions
	
	if patrol_timer <= patrol_timer_max:
		return target_global_positions	
	
	target_global_positions.clear()
	var random_angle: float = deg_to_rad(randf_range(-90, 90))
	var random_direction: Vector2 = current_direction.rotated(random_angle)
	var random_position: Vector2 = global_position + random_direction * 1000
	
	target_global_positions.append(random_position)
	patrol_timer = 0.0
	
	return target_global_positions
