class_name TargetFinderComponent extends Node

@export var _body: CharacterBody2D
@export var _target_group_name: String = "Players"
@export var _target_lost_timer_limit: float = 5.0
@export var _random_arc_angle_threshold: float = 90
@export var _random_position_offset: int = 1000

var _target_lost_timer: float = 0.0
var _target_global_positions: Array[Vector2]


func _ready():
	if not _body:
		push_error("Body not set")


func _physics_process(delta: float) -> void:
	_target_lost_timer = _target_lost_timer + delta


func find_first_target_in_group() -> Node:
	return get_tree().get_first_node_in_group(_target_group_name)


func _check_target_in_arc(target: Node, normalized_current_direction: Vector2) -> bool:
	var direction_to_target: Vector2 = (target.global_position - _body.global_position).normalized()
	var alignment_to_target: float = normalized_current_direction.dot(direction_to_target)
	return alignment_to_target


func find_next_target_position(normalized_current_direction: Vector2) -> Array[Vector2]:
	var target: Node = get_tree().get_first_node_in_group(_target_group_name)
	
	if target:
		var is_in_arc: bool = _check_target_in_arc(target, normalized_current_direction)
		if is_in_arc:
			_target_lost_timer = 0.0
			_target_global_positions.clear()
			_target_global_positions.append(target.global_position)
			return _target_global_positions
	
	if _target_lost_timer < _target_lost_timer_limit:
		return _target_global_positions
	
	_target_global_positions.clear()
	print("No target")
	
	var random_position: Vector2 = find_random_position_within_arc(normalized_current_direction)
	
	_target_global_positions.append(random_position)
	_target_lost_timer = 0.0
	
	return _target_global_positions


func find_random_position_within_arc(normalized_current_direction: Vector2) -> Vector2:
	var random_angle_in_arc: float = deg_to_rad(randf_range(-_random_arc_angle_threshold, _random_arc_angle_threshold))
	var random_direction: Vector2 = normalized_current_direction.rotated(random_angle_in_arc)
	var random_position: Vector2 = _body.global_position + (random_direction * _random_position_offset)
	return random_position
