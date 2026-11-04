class_name Navigator extends Node2D

@onready var raycaster: Node2D = $Raycaster

var ray_result_data: Array[RayResult]

func calculate_direction(
		target_global_positions: Array[Vector2],
		normalized_current_direction: Vector2,
		normalized_previous_direction: Vector2,
		collision_mask: int, 
		ray_exclusion_rid_array: Array[RID]) -> Vector2:
	ray_result_data = _calculate_ray_data(normalized_current_direction, 
		collision_mask, ray_exclusion_rid_array)
	var steering_calculator_settings = SteeringCalculatorSettings.new()
	
	steering_calculator_settings.source_global_position = global_position
	steering_calculator_settings.target_global_positions = target_global_positions
	steering_calculator_settings.normalized_previous_direction = normalized_previous_direction
	steering_calculator_settings.normalized_current_direction = normalized_current_direction
	steering_calculator_settings.ray_results = ray_result_data
	steering_calculator_settings.ray_length = raycaster.ray_length
	
	return SteeringCalculator.calculate_direction(steering_calculator_settings)


func _calculate_ray_data(current_direction: Vector2, 
		collision_mask: int, 
		ray_exclusion_rid_array: Array[RID]) -> Array[RayResult]:
	return raycaster.cast_rays_in_direction(current_direction, collision_mask, ray_exclusion_rid_array)
