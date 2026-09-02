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
var desired_direction: Vector2 = Vector2(1, 0) # Direction to goal
var steered_direction: Vector2 = Vector2(1, 0)

#var target_player: RigidBody2D
var current_state: EnemyState

var steering_timer: float
var distance_to_goal: float
var avoidance_vector: Vector2
var previous_avoidance_vector: Vector2

#temp
var raycast_weight_dict: Dictionary[Vector2, int]
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
	desired_direction = (target_player.global_position - global_position).normalized()


func _physics_process(delta: float) -> void:	
	#var raycast_target_positions := raycaster.calculate_raycast_target_positions(global_position, desired_direction)
	var raycast_result_data := raycaster.cast_rays_for_direction(desired_direction)
	var target_global_positions: Array[Vector2]
	target_global_positions.append(target_player.global_position)
	
	var exclusion_rid_array: Array[RID] = [self.get_rid(), target_player.get_rid()]
	#var steering_manager_settings = SteeringManagerSettings.new()
	#steering_manager_settings.source_global_position = global_position
	#steering_manager_settings.target_global_positions = target_global_positions
	#steering_manager_settings.raycast_target_positions = raycast_target_positions
	#steering_manager_settings.degrees_between_raycasts = raycaster.degrees_between_raycasts
	#steering_manager_settings.current_direction = Vector2.LEFT
	#steering_manager_settings.space_state = get_world_2d().direct_space_state
	#steering_manager_settings.exclusion_rid_array = exclusion_rid_array
	#steering_manager_settings.collision_mask = collision_mask
	#var weighted_goal_direction: Vector2 = steering_manager.calculate(steering_manager_settings)
#
	#velocity = weighted_goal_direction * move_speed
	velocity = Vector2.LEFT * move_speed
	
	move_and_slide()


func test():
	for raycast_target: Vector2 in raycaster.calculate_raycast_target_positions(global_position, (target_player.global_position - global_position).normalized()):
		var raycast_query = PhysicsRayQueryParameters2D.create(
			global_position,
			raycast_target
		)
		
		raycast_query.exclude = [self]
		var raycast_result := get_world_2d().direct_space_state.intersect_ray(raycast_query)
		print(raycast_result)
		
		if raycast_result:
			print(raycast_result.collider.name)
