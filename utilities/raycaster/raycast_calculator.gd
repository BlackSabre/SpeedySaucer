class_name RaycastCalculator extends RefCounted

static func calculate_raycast_target_positions(
	raycaster_settings: RaycastSettings) -> PackedVector2Array:
	var current_direction := raycaster_settings.current_direction
	if (current_direction.is_zero_approx()):
		return PackedVector2Array()
	
	var source_global_position := raycaster_settings.source_global_position
	var ray_length := raycaster_settings.ray_length
	var number_of_raycasts := raycaster_settings.number_of_raycasts
	var degrees_between_raycasts := raycaster_settings.degrees_between_raycasts	
	var raycast_target_position_array := PackedVector2Array()
	var raycasts_per_side = floor(number_of_raycasts / 2.0)
	var number_of_raycasts_offset := 0.5 if number_of_raycasts % 2 == 0 else 0.0
	var normalized_direction: Vector2 = current_direction.normalized()
	
	for i in range(number_of_raycasts):
		var raycast_index: float = i - raycasts_per_side + number_of_raycasts_offset
		var raycast_direction_offset: float = deg_to_rad(degrees_between_raycasts * raycast_index)
		var direction: Vector2 = normalized_direction.rotated(raycast_direction_offset) * ray_length
		raycast_target_position_array.append(source_global_position + direction)
	
	return raycast_target_position_array


static func calculate_raycast_target_directions(raycaster_settings: RaycastSettings) -> PackedVector2Array:
	var current_direction := raycaster_settings.current_direction
	if (current_direction.is_zero_approx()):
		return PackedVector2Array()
	
	var number_of_raycasts := raycaster_settings.number_of_raycasts
	var degrees_between_raycasts := raycaster_settings.degrees_between_raycasts
	var raycast_target_direction_array := PackedVector2Array()
	var raycasts_per_side = floor(number_of_raycasts / 2.0)
	var number_of_raycasts_offset := 0.5 if number_of_raycasts % 2 == 0 else 0.0
	var normalized_direction: Vector2 = current_direction.normalized()
	
	for i: int in range(number_of_raycasts):
		var raycast_index: float = i - raycasts_per_side + number_of_raycasts_offset
		var raycast_direction_offset = deg_to_rad(degrees_between_raycasts * raycast_index)
		var direction: Vector2 = normalized_direction.rotated(raycast_direction_offset)
		raycast_target_direction_array.append(direction)
	
	return raycast_target_direction_array
