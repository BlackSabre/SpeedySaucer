class_name RayResult extends Resource

var normalized_direction: Vector2
var target_position: Vector2
var hit: bool = false
var hit_position: Vector2
var normal: Vector2
var distance_to_hit: float
var collider: Variant

func print_values():
	var direction_str = "direction: %s, target_position: %s, hit_position: %s, distance_to_hit: %s, collider: %s" % [normalized_direction, target_position, hit_position, distance_to_hit, collider.name if hit else null]
	print(direction_str)
