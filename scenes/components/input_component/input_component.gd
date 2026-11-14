class_name InputComponent extends Node2D

@export var _movement_force: float = 1000.0

signal left_mouse_clicked(global_mouse_position)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed:
		left_mouse_clicked.emit(get_global_mouse_position())
		get_viewport().set_input_as_handled()
		

func calculate_vector_force() -> Vector2:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var vector_force: Vector2 = input_vector * _movement_force;
	return vector_force


func get_direction_to_mouse_pointer(source_node: Node2D) -> Vector2:
	return source_node.global_position.direction_to(source_node.get_global_mouse_position())
