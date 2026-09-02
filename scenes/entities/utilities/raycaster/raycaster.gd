class_name Raycaster extends Node2D

@export_range(1, 5000)
var raycast_length: int = 800

@export_range(1, 100) 
var number_of_raycasts: int = 2

@export_range(1, 180)
var degrees_between_raycasts: int = 10

@export var debug: bool = false

@export_range(1, 50) var ray_thickness: int = 5

var _raycast_result_array: Array[RaycastResult] = []
var _space_state: PhysicsDirectSpaceState2D
var _raycast_settings: RaycastSettings

func _ready() -> void:
	_raycast_settings = RaycastSettings.new()
	_space_state = get_world_2d().direct_space_state
	_raycast_settings.raycast_length = raycast_length
	_raycast_settings.number_of_raycasts = number_of_raycasts
	_raycast_settings.degrees_between_raycasts = degrees_between_raycasts


func cast_rays_for_direction(current_direction: Vector2) \
	 -> Array[RaycastResult]:
	cast_rays_in_direction(current_direction)
	return _raycast_result_array


func cast_rays_in_direction(current_direction: Vector2) -> void:
	_raycast_result_array.clear()
	
	_raycast_settings.current_direction = current_direction
	var ray_directions: PackedVector2Array = \
		RaycastCalculator.calculate_raycast_target_directions(_raycast_settings)
	
	for direction: Vector2 in ray_directions:
		var target_position: Vector2 = global_position + (direction * raycast_length)
		var intersection_data_dict := cast_ray(target_position)
		var raycast_result := _process_ray(direction, target_position, intersection_data_dict)
		_raycast_result_array.append(raycast_result)
		
	if debug:
		_highlight_obstacles()
		queue_redraw()


func cast_ray(target_position: Vector2) -> Dictionary:	
	var raycast_query_parameters := PhysicsRayQueryParameters2D.create(
		global_position,
		target_position
	)
	
	return _space_state.intersect_ray(raycast_query_parameters)


func _process_ray(direction: Vector2, target_position: Vector2, 
	intersection_data_dict: Dictionary) -> RaycastResult:
	var raycast_result := RaycastResult.new()
	raycast_result.direction = direction
	raycast_result.target_position = target_position
	raycast_result.hit = false
	raycast_result.collider = null
	raycast_result.hit_position = Vector2.ZERO
	raycast_result.distance_to_hit = 0
		
	if intersection_data_dict:
		raycast_result.hit = true
		raycast_result.hit_position = intersection_data_dict.position
		raycast_result.distance_to_hit = global_position.distance_to(intersection_data_dict.position)
		raycast_result.target_position = raycast_result.hit_position
		raycast_result.collider = intersection_data_dict.collider
	
	return raycast_result


func _highlight_obstacles() -> void:
	for ray_result: RaycastResult in _raycast_result_array:
		if not(ray_result.hit):
			continue
		
		var obstacle = ray_result.collider
		if obstacle.has_method("outline_sprite"):
			obstacle.outline_sprite()


func _draw() -> void:
	if not debug:
		return
	
	for raycast: RaycastResult in _raycast_result_array:
		if raycast.hit:
			draw_line(
				Vector2.ZERO,
				to_local(raycast.target_position),
				Color.RED, 
				ray_thickness
			)
		else:
			draw_line(
				Vector2.ZERO,
				to_local(raycast.target_position),
				Color.GREEN, 
				ray_thickness
			)
