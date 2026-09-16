class_name SteeringManagerSettings extends Resource

var source_global_position: Vector2
var target_global_positions: Array[Vector2]
var normalized_current_direction: Vector2
var ray_target_positions: PackedVector2Array
var ray_length: int
var ray_results: Array[RayResult]
var degrees_between_raycasts: int
var space_state: PhysicsDirectSpaceState2D
var collision_mask: int
var exclusion_rid_array: Array[RID]
