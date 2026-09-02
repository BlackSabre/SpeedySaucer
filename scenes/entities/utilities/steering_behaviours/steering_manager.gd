class_name SteeringManager extends Node2D

var behaviours: Array[SteeringBehaviour]

func add_steering_behaviour(steering_behaviour: SteeringBehaviour):
	behaviours.append(steering_behaviour)


func calculate(steering_behaviour_settings: SteeringManagerSettings) -> Vector2:
	var source_global_position := steering_behaviour_settings.source_global_position
	var target_global_positions := steering_behaviour_settings.target_global_positions
	var raycast_target_positions := steering_behaviour_settings.raycast_target_positions
	var current_direction := steering_behaviour_settings.current_direction
	var space_state := steering_behaviour_settings.space_state
	var collision_mask := steering_behaviour_settings.collision_mask
	var exclusion_rid_array := steering_behaviour_settings.exclusion_rid_array
	var degrees_between_raycasts := steering_behaviour_settings.degrees_between_raycasts
	var interest_map_dict: Dictionary[Vector2, float]
	var danger_map_dict: Dictionary[Vector2, float]
	var raycast_length: float = source_global_position.distance_to(raycast_target_positions[0])
	var final_vector := Vector2.ZERO
	
	for raycast_target_position: Vector2 in raycast_target_positions:
		var raycast_target_direction = source_global_position.direction_to(raycast_target_position)
		var raycast_result: Dictionary = create_raycast(source_global_position, raycast_target_position,
							space_state, collision_mask, exclusion_rid_array)

		if raycast_result:
			var obstacle = raycast_result.collider
			print("obs: ", obstacle)
			if obstacle.has("outline_sprite"):
				obstacle.outline_sprite()
			
			var distance_to_obstacle := source_global_position.distance_to(raycast_result.position)
			danger_map_dict[raycast_target_direction] = 1.0 - (distance_to_obstacle / raycast_length)
		else:
			danger_map_dict[raycast_target_direction] = 0
	
		# Take into account the current direction
		var current_direction_raycast_weight = clampf(current_direction.dot(raycast_target_direction), 0, 0.1)
		#print("CD: ", current_direction_raycast_weight)
		interest_map_dict[raycast_target_direction] = current_direction_raycast_weight
	
		# Add first target global position, which should be the player.
		var direction_to_player = source_global_position.direction_to(target_global_positions[0])
		var player_weight = clampf(direction_to_player.dot(raycast_target_direction), 0, 0.2)
		interest_map_dict[raycast_target_direction] = clampf(interest_map_dict[raycast_target_direction] + player_weight, 0, 1)
	
	_print_dictionary_maps(interest_map_dict, "IM:")
	_print_dictionary_maps(danger_map_dict, "D0:")
	
	danger_map_dict = _apply_danger_propagation(danger_map_dict, raycast_target_positions, 
		degrees_between_raycasts)
	
	var final_interest_map_dict: Dictionary[Vector2, float]
	for direction in interest_map_dict.keys():
		var interest_value = interest_map_dict[direction]
		var danger_value = danger_map_dict[direction]
		var final_interest_value = clampf(interest_value - danger_value, 0.0, 1.0)
		var calculated_direction = direction * final_interest_value
		final_interest_map_dict[direction] = final_interest_value
		#print("calc: ", direction, " int: ", final_interest_value)
		final_vector += calculated_direction
	
	_print_dictionary_maps(final_interest_map_dict, "FM:")
	
	return final_vector.normalized()


func create_raycast(source_global_position: Vector2, 
	raycast_target_position: Vector2,
	space_state: PhysicsDirectSpaceState2D,
	collision_mask: int = -1,
	exclusion_rid_array: Array[RID] = []
	) -> Dictionary:
		var raycast_query_parameters = PhysicsRayQueryParameters2D.create(
			source_global_position,
			raycast_target_position,
			collision_mask
		)		
		raycast_query_parameters.exclude = exclusion_rid_array
		
		return space_state.intersect_ray(raycast_query_parameters)


func _apply_danger_propagation(danger_map_dict: Dictionary[Vector2, float],
	raycast_target_positions: PackedVector2Array,
	degrees_between_raycasts: int) -> Dictionary[Vector2, float]:	
	# Don't look at directions that are more than "propagation_degree_threshold" degrees away
	var propagation_degree_threshold: int = 20	
	if degrees_between_raycasts > propagation_degree_threshold:
		return danger_map_dict	
	
	if degrees_between_raycasts == 0:
		return danger_map_dict
	
	#var propagation_number_limit: int = 1
	
	var propagated_danger_map_dict: Dictionary[Vector2, float]
	for direction: Vector2 in danger_map_dict.keys():
		if direction.is_zero_approx():
			continue
		
		var current_weight: float = danger_map_dict[direction]
		if is_zero_approx(current_weight):
			continue
		
		var array_max_index = raycast_target_positions.size() - 1
		var array_index: int = raycast_target_positions.find(direction)
		var previous_index: int = array_index - 1 if array_index > 0 else array_max_index
		var next_index: int = array_index + 1 if array_index < array_max_index else 0
		var previous_direction: Vector2 = raycast_target_positions[previous_index]
		var next_direction: Vector2 = raycast_target_positions[next_index]
		var previous_dot_product: float = direction.dot(previous_direction)
		var next_dot_product: float = direction.dot(next_direction)
		var angle_to_previous: float = direction.angle_to(previous_direction)
		var angle_to_next: float = rad_to_deg(next_direction.angle())
		var propagation_weight: float = 0		
		print("prev: ", absf(rad_to_deg(direction.angle_to(previous_direction))))
		print("curr: ", absf(rad_to_deg(direction.angle_to(direction))))
		print("next: ", absf(rad_to_deg(direction.angle_to(next_direction))))
		propagated_danger_map_dict[direction] = propagation_weight
	
	for direction: Vector2 in propagated_danger_map_dict.keys():
		#danger_map_dict[direction] += clampf(propagated_danger_map_dict[direction], 0, 1)
		pass
	
	_print_dictionary_maps(propagated_danger_map_dict, "PD:")
	_print_dictionary_maps(danger_map_dict, "D1:")
	return danger_map_dict

func _print_dictionary_maps(dictionary_map: Dictionary[Vector2, float], dictionary_name: String = ""):
	var print_string: String = dictionary_name + " " if dictionary_name != "" else ""
	for direction: Vector2 in dictionary_map.keys():
		var direction_formatted: String = "%1.3v" % direction
		var weight_formatted: String = "%1.4f" % dictionary_map[direction]
		print_string += "D: {dir}, W: {weight};  ".format({"dir": direction_formatted, "weight": weight_formatted})		
	print(print_string)
	
func chase_behaviour():
	pass
