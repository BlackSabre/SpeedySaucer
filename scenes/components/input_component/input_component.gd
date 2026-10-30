class_name InputComponent extends Node

@export var movement_force: float = 1000.0

func calculate_vector_force() -> Vector2:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var vector_force: Vector2 = input_vector * movement_force;
	return vector_force


func get_direction_to_mouse_pointer(source_node: Node2D) -> Vector2:
	return source_node.global_position.direction_to(source_node.get_global_mouse_position())
