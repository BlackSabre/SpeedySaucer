class_name SteeringManager extends Node2D

func calculate_direction(steering_manager_settings: SteeringManagerSettings) -> Vector2:
	var interest_weights: Array[float] = []
	var danger_weights: Array[float] = []
	var final_interest_weights: Array[float] = []
	var source_global_position: Vector2 = steering_manager_settings.source_global_position
	var target_global_positions: Array[Vector2] = steering_manager_settings.target_global_positions
	var normalized_current_direction: Vector2 = steering_manager_settings.normalized_current_direction
	var ray_results: Array[RayResult] = steering_manager_settings.ray_results
	var ray_length: int = steering_manager_settings.ray_length
	
	assert(ray_length > 0)
	
	for ray: RayResult in ray_results:
		var danger_weight: float = _calculate_danger_weight(ray, ray_length)
		var interest_weight: float = _calculate_interest_weight(ray, normalized_current_direction, source_global_position, target_global_positions)
		
		danger_weights.append(danger_weight)
		interest_weights.append(interest_weight)
	
	danger_weights = _propagate_danger_weights(danger_weights)
	
	# Subtract danger weights from interest weights and apply to direction
	for i in interest_weights.size():
		var calculated_weight: float = clampf(interest_weights[i] - danger_weights[i], 0, 1)
		final_interest_weights.append(calculated_weight)
	
	
	var final_direction: Vector2 = _calculate_final_direction(final_interest_weights, ray_results)
	_do_wall_stuff(final_direction, ray_results)
	return final_direction


func _calculate_danger_weight(ray: RayResult, ray_length: int) -> float:
	var weight: float = 0
	if ray.hit:
		weight = clampf(1 - (ray.distance_to_hit / ray_length), 0, 1)
	
	return weight


func _calculate_interest_weight(ray: RayResult, 
	normalized_current_direction: Vector2, 
	source_global_position: Vector2, 
	target_global_positions: Array[Vector2]) -> float:
	
	var highest_weight: float = 0
	
	for target_position: Vector2 in target_global_positions:
		var direction_to_target = source_global_position.direction_to(target_position)
		var target_alignment = clampf(direction_to_target.dot(ray.normalized_direction), 0, 1)
		var current_direction_alignment = clampf(ray.normalized_direction.dot(normalized_current_direction), 0, 1)
		var weight: float = (target_alignment * 0.8) + (current_direction_alignment * 0.2)

		# Use highest interest as the final weight
		highest_weight = max(highest_weight, weight)
	
	return highest_weight


func _propagate_danger_weights(danger_weights: Array[float]) -> Array[float]:
	if danger_weights.is_empty():
		return danger_weights
	
	var propagated_weights: Array[float] = danger_weights.duplicate()
	for i: int in danger_weights.size():
		var weight: float = danger_weights[i]
		
		if is_zero_approx(weight):
			continue
		
		var propagated_weight: float = weight * 0.6
		
		if i > 0:
			propagated_weights[i - 1] = max(
				propagated_weights[i - 1],
				propagated_weight
			)
		
		if i < danger_weights.size() - 1:
			propagated_weights[i + 1] = max(
				propagated_weights[i + 1],
				propagated_weight
			)
		
	return propagated_weights


func _calculate_final_direction(final_interest_weights: Array[float], ray_results: Array[RayResult]) -> Vector2:
	if final_interest_weights.is_empty():
		return Vector2.ZERO
	
	var best_weight_index: int = 0
	for i: int in range(1, final_interest_weights.size()):
		if final_interest_weights[i] > final_interest_weights[best_weight_index]:
			best_weight_index = i
	
	var best_weight: float = final_interest_weights[best_weight_index]
	
	if is_zero_approx(best_weight):
		return Vector2.ZERO
	
	var final_direction: Vector2 = ray_results[best_weight_index].normalized_direction * best_weight
	var minimum_blend_weight: float = best_weight * 0.5
	
	# Blend previous neighbouring directions
	if best_weight_index > 0:
		var previous_weight_index: int = best_weight_index - 1
		var previous_weight: float = final_interest_weights[previous_weight_index]
		
		if previous_weight >= minimum_blend_weight:
			final_direction += ray_results[previous_weight_index].normalized_direction * previous_weight
		
	# Blend next neighbouring direction
	if best_weight_index < final_interest_weights.size() - 1:
		var next_weight_index: int = best_weight_index + 1
		var next_weight = final_interest_weights[next_weight_index]
		
		if next_weight >= minimum_blend_weight:
			final_direction += ray_results[next_weight_index].normalized_direction * next_weight
		
	return final_direction.normalized()


func _do_wall_stuff(direction: Vector2, ray_results: Array[RayResult]):
	pass
