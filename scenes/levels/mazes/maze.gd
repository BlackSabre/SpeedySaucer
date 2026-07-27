extends Area2D

@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D
@onready var player_node = $"../Player"

signal player_out_of_bounds

func _physics_process(_delta: float) -> void:
	if (!player_node):
		print("Player not found")
		return
		
	var points_to_check = player_node.get_saucer_edge_points()
	for point in points_to_check:
		if not is_point_inside_maze(point):
			#emit_signal("player_out_of_bounds")
			pass


func is_point_inside_maze(point: Vector2) -> bool:
	var local_point = collision_polygon.to_local(point)
	return Geometry2D.is_point_in_polygon(local_point, collision_polygon.polygon)
