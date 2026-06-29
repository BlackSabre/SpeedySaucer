extends Node2D

@export var number_of_raycasts: int = 3
@export var raycast_length: int = 700
@export var degrees_between_raycasts: int = 60

@export_category("Debugging Options")
@export var enable_debug_lines: bool = true


func create_raycast_vectors() -> void:
	pass

#func _draw():
	#var current_direction := Vector2(1,-1)
	#var raycast_direction_offset = deg_to_rad(degrees_between_raycasts)
	#var direction = current_direction.normalized().rotated(raycast_direction_offset) * raycast_length
	#var to_points: Array[Vector2]
	##print("DrDir: ", direction)
	##print("DrLen: ", direction.length())
	#
	##to_points.append(to_local(global_position + direction))
	#
	#direction = current_direction.normalized().rotated(-raycast_direction_offset) * raycast_length
	#to_points.append(to_local(global_position + direction))
	#
	##print(scale)
	##print(global_scale)
	##print(some_direction)
	#
	##var to_point = Vector2.RIGHT * 500
	##degrees_between_raycasts = 180
	##var to_point = Vec tor2.RIGHT.rotated(deg_to_rad(degrees_between_raycasts)) * 500
	#for point in to_points:
		#draw_line(Vector2.ZERO, point, Color.GREEN, 5)
	

func calculate_collision_steering_vector2() -> void:
	pass
