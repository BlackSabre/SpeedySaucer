class_name Navigator extends Node2D

@onready var raycaster: Node2D = $Raycaster

var ray_result_data: Array[RayResult]

func calculate_direction(
		target_global_posiions: Array[Vector2],
		normalized_current_direction: Vector2,
		normalized_previous_direction: Vector2,
		collision_mask: int, 
		ray_exclusion_rid_array: Array[RID]) -> Vector2:
	ray_result_data = _calculate_ray_data(normalized_current_direction, 
		collision_mask, ray_exclusion_rid_array)
	return _calculate_direction(
		target_global_posiions, 
		normalized_current_direction, 
		normalized_previous_direction)


func _calculate_ray_data(current_direction: Vector2, 
		collision_mask: int, 
		ray_exclusion_rid_array: Array[RID]) -> Array[RayResult]:
	return raycaster.cast_rays_in_direction(current_direction, collision_mask, ray_exclusion_rid_array)


func _calculate_direction(
	target_global_positions: Array[Vector2],
	normalized_current_direction: Vector2,
	normalized_previous_direction: Vector2
	) -> Vector2:
	var steering_manager_settings = SteeringManagerSettings.new()
	
	steering_manager_settings.source_global_position = global_position
	steering_manager_settings.target_global_positions = target_global_positions
	steering_manager_settings.normalized_previous_direction = normalized_previous_direction
	steering_manager_settings.normalized_current_direction = normalized_current_direction
	steering_manager_settings.ray_results = ray_result_data
	steering_manager_settings.ray_length = raycaster.ray_length
	
	return SteeringManager.calculate_direction(steering_manager_settings)
