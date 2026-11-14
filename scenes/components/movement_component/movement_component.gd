class_name MovementComponent extends Node

@export var _body: CharacterBody2D
@export var _navigator: Navigator
@export var _move_speed: float = 300.0
@export var _turn_rate: float = 1.0
@export var _max_rotation_weight: float = 1.0

var _normalized_current_direction := Vector2.ZERO
var _normalized_previous_direction := Vector2.ZERO
var _target_body: Node = null
var _ray_exclusion_rid_array: Array[RID]

func _ready():
	setup()


func get_normalized_current_direction() -> Vector2:
	return _normalized_current_direction
	

func setup():
	if not _body: 
		push_error("Body not configured")
		return
	
	_ray_exclusion_rid_array = [_body.get_rid()]
	_normalized_current_direction = Vector2.LEFT


func move_towards(target_body: Node, target_global_position: Vector2) -> Vector2:
	if target_body:
		_target_body = target_body
		if target_body.has_method("get_rid"):
			var target_rid: RID = target_body.get_rid()
			if not _ray_exclusion_rid_array.has(target_rid):
				_ray_exclusion_rid_array.append(target_rid)
	
	var weighted_goal_direction: Vector2 = _navigator.calculate_direction(
		[target_global_position],
		_normalized_current_direction,
		_normalized_previous_direction,
		_body.collision_mask,
		_ray_exclusion_rid_array)
	
	_normalized_previous_direction = _normalized_current_direction
	var direction_lerp_weight: float = 1.0 - exp(-_turn_rate * get_physics_process_delta_time())
	var lerped_direction: Vector2 = lerp(_normalized_current_direction, weighted_goal_direction, direction_lerp_weight).normalized()
	if not lerped_direction.is_zero_approx():
		_normalized_current_direction = lerped_direction
	
	_rotate()
	return _normalized_current_direction * _move_speed


func _rotate() -> void:
	var angle_current_direction = _normalized_current_direction.angle()
	_body.rotation = lerp_angle(_body.rotation, angle_current_direction, _max_rotation_weight)
