extends CharacterBody2D

@export var move_speed: float = 300
@export var turn_speed: float = 2
@export var max_turn_radians: float = 5
@export var attack_move_speed: float = 750
@export var accleration_factor: float = 50
@export var raycaster: Raycaster
@export var steering_manager: SteeringManager

@export var angle_slerp_switch: float = 0.55
@export var continuous_slerp_rate: float = 3.0
@export var abort_attack_distance_threshold: int = 1500
@export var abort_turn_distance_threshold: int = 900
@export var start_turn_distance_threshold: int = 800

@export var steering_slerp_weight: float = 0.2
@export var steering_interval: float = 0.05

var current_speed: float
var target_speed: float
var current_direction: Vector2 = Vector2(1, 0)
var desired_normalized_direction: Vector2 = Vector2(1, 0)
var steered_direction: Vector2 = Vector2(1, 0)

#var target_player: RigidBody2D
var current_state: EnemyState

var steering_timer: float
var distance_to_goal: float
var avoidance_vector: Vector2
var previous_avoidance_vector: Vector2

#temp
var target_player

enum EnemyState {
	CREATE_DISTANCE,
	ATTACK_RUN,
	TURNING
}


func _ready() -> void:
	current_speed = move_speed
	current_state = EnemyState.CREATE_DISTANCE
	target_player = get_tree().get_first_node_in_group("Players")
	desired_normalized_direction = (target_player.global_position - global_position).normalized()
	look_at(target_player.global_position)


func _physics_process(_delta: float) -> void:
	var ray_result_data: Array[RayResult] = _calculate_ray_data()
	var weighted_goal_direction: Vector2 = _calculate_direction(ray_result_data)
	
	var angle = weighted_goal_direction.angle()
	print(weighted_goal_direction)
	
	rotation = lerp_angle(rotation, angle, 0.05)
	velocity = weighted_goal_direction * move_speed
	 
	move_and_slide()


func _calculate_ray_data() -> Array[RayResult]:
	var ray_exclusion_rid_array: Array[RID] = [self.get_rid(), target_player.get_rid()]
	desired_normalized_direction = (target_player.global_position - global_position).normalized()
	return raycaster.cast_rays_in_direction(desired_normalized_direction, collision_mask, ray_exclusion_rid_array)


func _calculate_direction(ray_result_data: Array[RayResult]):
	var steering_manager_settings = SteeringManagerSettings.new()
	var target_global_positions: Array[Vector2]
	
	target_global_positions.append(target_player.global_position)
	steering_manager_settings.source_global_position = global_position
	steering_manager_settings.target_global_positions = target_global_positions
	steering_manager_settings.normalized_current_direction = Vector2.RIGHT
	steering_manager_settings.ray_results = ray_result_data
	steering_manager_settings.target_global_positions = target_global_positions
	steering_manager_settings.ray_length = raycaster.ray_length
	
	return steering_manager.calculate_direction(steering_manager_settings)
