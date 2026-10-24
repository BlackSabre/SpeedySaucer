extends CharacterBody2D

@export var move_speed: float = 300
@export var turn_rate: float = 1
@export var max_rotation_weight: float = 0.2
@export var enemy_weapon: EnemyWeapon
@export var projectile_parent: Node
@export var alignment_to_player_firing_threshold: float = 0.96
@export var random_direction_angle_threshold: float = 90
@export var random_position_offset: int = 1000
@export var push_force: float = 10.0

@onready var navigator: Navigator = $Navigator

var normalized_current_direction := Vector2.LEFT
var normalized_previous_direction: Vector2
var patrol_timer: float = 0.0
var patrol_timer_max: float = 5.0
var target_player: RigidBody2D
var target_global_positions: Array[Vector2]
var direction_to_player: Vector2


func _ready() -> void:
	target_player = get_tree().get_first_node_in_group("Players")
	
	if target_player:
		normalized_current_direction = (target_player.global_position - global_position).normalized()
		target_global_positions.append(target_player.global_position)
		look_at(target_player.global_position)


func _physics_process(delta: float) -> void:
	if target_global_positions.size() > 0:
		target_global_positions = _find_next_target(delta)
		velocity = _calculate_velocity(delta)
	
	var angle_current_direction = normalized_current_direction.angle()
	rotation = lerp_angle(rotation, angle_current_direction, max_rotation_weight)
	fire()
	move_and_slide()
	apply_forces()


func _calculate_velocity(delta: float) -> Vector2:
	var ray_exclusion_rid_array: Array[RID] = [self.get_rid()]
	if target_player:
		ray_exclusion_rid_array.append(target_player.get_rid())
		
	var weighted_goal_direction: Vector2 = navigator.calculate_direction(
		target_global_positions,
		normalized_current_direction,
		normalized_previous_direction,
		collision_mask,
		ray_exclusion_rid_array)
	
	var direction_lerp_weight: float = 1.0 - exp(-turn_rate * delta)
	normalized_previous_direction = normalized_current_direction
	
	var lerped_direction: Vector2 = lerp(normalized_current_direction, weighted_goal_direction, direction_lerp_weight).normalized()
	if not lerped_direction.is_zero_approx():
		normalized_current_direction = lerped_direction
	
	return normalized_current_direction * move_speed


func fire():
	var direction_player_alignment: float = direction_to_player.dot(normalized_current_direction)
	if direction_player_alignment > alignment_to_player_firing_threshold:
		enemy_weapon.fire_weapon(normalized_current_direction, projectile_parent)


func apply_forces() -> void:
	for i: int in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			#collision.get_collider().apply_central_impulse(-collision.get_normal() * push_force)
			collision.get_collider().apply_impulse(-collision.get_normal() * push_force * 10)
		
		

# Returns the player global position if ahead of the enemy, otherwise returns a random
# global_position. Does not currently support having multiple targets
func _find_next_target(delta: float) -> Array[Vector2]:
	patrol_timer += delta
	
	if target_player:
		direction_to_player = (target_player.global_position - global_position).normalized()
		var enemy_player_alignment: float = normalized_current_direction.dot(direction_to_player)
		if enemy_player_alignment > 0:
			target_global_positions.clear()
			target_global_positions.append(target_player.global_position)
			patrol_timer = 0.0
			return target_global_positions
	
	if patrol_timer <= patrol_timer_max:
		return target_global_positions
	
	target_global_positions.clear()
	var random_angle: float = deg_to_rad(randf_range(-random_direction_angle_threshold, random_direction_angle_threshold))
	var random_direction: Vector2 = normalized_current_direction.rotated(random_angle)
	var random_position: Vector2 = global_position + (random_direction * random_position_offset)
	
	target_global_positions.append(random_position)
	patrol_timer = 0.0
	
	return target_global_positions
