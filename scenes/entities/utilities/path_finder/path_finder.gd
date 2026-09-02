class_name PathFinder extends RefCounted

static func calculate_target_vector(path_finder_settings: PathFinderSettings) -> Vector2:
	var source_global_position := path_finder_settings.source_global_position
	var goal_global_position := path_finder_settings.goal_global_position
	var raycast_target_positions := path_finder_settings.raycast_target_positions
	var space_state := path_finder_settings.space_state
	var collision_mask := path_finder_settings.collision_mask
	var exclusion_rid_array := path_finder_settings.exclusion_rid_array
	var weighted_goal_direction := Vector2.ZERO
	var goal_direction: Vector2 = source_global_position.direction_to(goal_global_position)
		
	if goal_direction.is_zero_approx():		
		return Vector2.ZERO
		
	for target: Vector2 in raycast_target_positions:		
		var direction_to_target := source_global_position.direction_to(target)
		
		# not interested in negative values that point away from the player
		var goal_alignment: float = clampf(
			direction_to_target.dot(goal_direction),
			0.0,
			1.0
		)
		
		var ray_query = PhysicsRayQueryParameters2D.create(
			source_global_position,
			target,
			collision_mask
		)
		
		ray_query.exclude = exclusion_rid_array
		
		var obstacle_clearance := 1.0
		var intersection_result := space_state.intersect_ray(ray_query)
		var danger := 0.0
		
		if intersection_result:
			var distance_to_obstacle := source_global_position.distance_to(intersection_result.position)	
			var ray_length := source_global_position.distance_to(target)
			var obstacle_proximity := 1.0 - (distance_to_obstacle - ray_length)
			danger = obstacle_proximity
			obstacle_clearance = distance_to_obstacle / ray_length
		
		var weight := maxf(goal_alignment - danger, 0.0)
		weighted_goal_direction += direction_to_target * weight
	
	return weighted_goal_direction.normalized()
