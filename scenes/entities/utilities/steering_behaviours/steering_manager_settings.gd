class_name SteeringManagerSettings extends Resource

var source_global_position: Vector2
var target_global_positions: Array[Vector2]
var current_direction: Vector2
var raycast_target_positions: PackedVector2Array
var degrees_between_raycasts: int
var space_state: PhysicsDirectSpaceState2D
var collision_mask: int
var exclusion_rid_array: Array[RID]
