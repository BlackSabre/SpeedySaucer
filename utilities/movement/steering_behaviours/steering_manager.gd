class_name SteeringManager extends RefCounted

static func calculate_direction(steering_manager_settings: SteeringManagerSettings) -> Vector2:
	var interest_weights: Array[float] = []
	var danger_weights: Array[float] = []
	var final_interest_weights: Array[float] = []
	var source_global_position: Vector2 = steering_manager_settings.source_global_position
	var target_global_positions: Array[Vector2] = steering_manager_settings.target_global_positions
	var normalized_current_direction: Vector2 = steering_manager_settings.normalized_current_direction
	var normalized_previous_direction: Vector2 = steering_manager_settings.normalized_previous_direction
	var ray_results: Array[RayResult] = steering_manager_settings.ray_results
	var ray_length: int = steering_manager_settings.ray_length
	
	assert(ray_length > 0)
	assert(target_global_positions.size() > 0)
	
	ray_results = _detect_wall_hits(ray_results)
	
	for ray: RayResult in ray_results:
		var danger_weight: float = _calculate_danger_weight(ray, ray_length)
		var interest_weight: float = _calculate_interest_weight(ray, normalized_current_direction, normalized_previous_direction, source_global_position, target_global_positions)
		
		danger_weights.append(danger_weight)
		interest_weights.append(interest_weight)
	
	danger_weights = _propagate_danger_weights(danger_weights)
	interest_weights = _avoid_blocked_regions(ray_results, interest_weights, danger_weights, normalized_current_direction)
	
	# Subtract danger weights from interest weights and apply to direction
	for i: int in interest_weights.size():
		var calculated_weight: float = clampf(interest_weights[i] - danger_weights[i], 0, 1)
		final_interest_weights.append(calculated_weight)	
	
	var final_direction: Vector2 = _calculate_final_direction(final_interest_weights, ray_results)
	#print(final_direction)
	return final_direction


static func _calculate_danger_weight(ray: RayResult, ray_length: int) -> float:
	var weight: float = 0
	if ray.hit:
		weight = clampf(1 - (ray.distance_to_hit / ray_length), 0, 1)

	return weight


static func _calculate_interest_weight(ray: RayResult, 
	normalized_current_direction: Vector2, 
	normalized_previous_direction: Vector2,
	source_global_position: Vector2, 
	target_global_positions: Array[Vector2]) -> float:
	
	var highest_weight: float = 0
	
	for target_position: Vector2 in target_global_positions:
		var direction_to_target: Vector2 = source_global_position.direction_to(target_position)
		var target_alignment: float = clampf(direction_to_target.dot(ray.normalized_direction), 0, 1)
		var current_direction_alignment: float = clampf(ray.normalized_direction.dot(normalized_current_direction), 0, 1)
		var previous_direction_alignment: float = clampf(ray.normalized_direction.dot(normalized_previous_direction), 0, 1)
		
		# Below weights should not sum past 1.0
		const TARGET_WEIGHT: float = 0.8
		const CURRENT_DIRECTION_WEIGHT: float = 0.15
		const PREVIOUS_DIRECTION_WEIGHT: float = 1.0 - TARGET_WEIGHT - CURRENT_DIRECTION_WEIGHT
		
		var weight: float = (target_alignment * TARGET_WEIGHT) + \
			(current_direction_alignment * CURRENT_DIRECTION_WEIGHT) + \
			(previous_direction_alignment * PREVIOUS_DIRECTION_WEIGHT)

		# Use highest interest as the final weight
		highest_weight = maxf(highest_weight, weight)
		
	return highest_weight


static func _propagate_danger_weights(danger_weights: Array[float]) -> Array[float]:
	if danger_weights.is_empty():
		return danger_weights
	
	var propagated_weights: Array[float] = danger_weights.duplicate()
	var neighbour_propagation_limit: int = 2 # number of neigbouring rays to spread danger to
	var number_of_weights: int = danger_weights.size()
	var danger_spread_factor: float = 0.6
	
	for i: int in number_of_weights:
		for offset: int in range(1, neighbour_propagation_limit + 1):
			var distance_decay_spread: float = pow(danger_spread_factor, offset)
			
			if i - offset >= 0:
				propagated_weights[i] = maxf(propagated_weights[i], 
					danger_weights[i - offset] * distance_decay_spread)
			
			if i + offset < number_of_weights:
				propagated_weights[i] = maxf(propagated_weights[i],
					danger_weights[i + offset] * distance_decay_spread)
		
	return propagated_weights


static func _calculate_final_direction(final_interest_weights: Array[float], ray_results: Array[RayResult]) -> Vector2:
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
		var next_weight: float = final_interest_weights[next_weight_index]
		
		if next_weight >= minimum_blend_weight:
			final_direction += ray_results[next_weight_index].normalized_direction * next_weight
		
	return final_direction.normalized()


# Marks rays as a wall if there are a certain number of sequental ray hits
static func _detect_wall_hits(ray_results: Array[RayResult]) -> Array[RayResult]:
	var ray_wall_threshold: int = maxi(int(ray_results.size() / 4.0), 4) # The number of sequential rays to assume a wall exists
	var successive_hits: int = 0
	
	# Clear all is_wall flags
	for ray: RayResult in ray_results:
		ray.is_wall = false
	
	for ray_index in ray_results.size():
		var ray: RayResult = ray_results[ray_index]
		if not(ray.hit):
			successive_hits = 0
			continue
		
		successive_hits += 1
		if successive_hits >= ray_wall_threshold:
			# Treating this and previous hits as walls, so we need to backtrack and
			# mark them as such
			for i in range(0, ray_wall_threshold): 
				ray_results[ray_index - i].is_wall = true
	
	return ray_results


# Attempts to avoid sequential regions of blocked ray casts.
static func _avoid_blocked_regions(ray_results: Array[RayResult], 
	interest_weights: Array[float],
	danger_weights: Array[float],
	normalized_current_direction: Vector2) -> Array[float]:
	if ray_results.is_empty():
		return interest_weights

	const BLOCKED_DANGER_THRESHOLD: float = 0.5 # Danger at or above this counts as blocked
	const MIN_VIABLE_INTEREST: float = 0.3 # Best final interest below this counts as stuck
	
	var wall_exists: bool = false
	var best_raw_interest: float = 0.0
	var best_final_interest: float = 0.0
	var most_aligned_weight: float = -INF # Interest weight that is most aligned to the current direction
	var most_aligned_ray_index: int = -1 # Ray index that is most aligned to the current direction
	
	for i: int in range(ray_results.size()):
		var ray: RayResult = ray_results[i]
		if ray.is_wall:
			wall_exists = true
		
		best_raw_interest = maxf(best_raw_interest, interest_weights[i])
		best_final_interest = maxf(best_final_interest, interest_weights[i] - danger_weights[i])
		
		# Candidate fallback: an unobstructed, low-danger ray closest to the current heading
		if not ray.hit and danger_weights[i] < BLOCKED_DANGER_THRESHOLD:
			var alignment: float = normalized_current_direction.dot(ray.normalized_direction)
			if alignment > most_aligned_weight:
				most_aligned_weight = alignment
				most_aligned_ray_index = i
		
	# Nothing to fix: no walls, no target, or a good option already exists
	if not wall_exists or is_zero_approx(best_raw_interest):
		return interest_weights
	if best_final_interest >= MIN_VIABLE_INTEREST:
		return interest_weights
	
	if most_aligned_ray_index >= 0:
		interest_weights[most_aligned_ray_index] = 1.0
	else:
		# No safe ray exists. Pick the first or last ray depending on current direction
		var last_index: int = ray_results.size() - 1
		var first_dot: float = normalized_current_direction.dot(ray_results[0].normalized_direction)
		var last_dot: float = normalized_current_direction.dot(ray_results[last_index].normalized_direction)
		interest_weights[0 if first_dot > last_dot else last_index] = 1.0

	return interest_weights
