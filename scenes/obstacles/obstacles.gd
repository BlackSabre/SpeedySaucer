class_name Obstacles extends Node


@export var _meteor_scene: PackedScene

var _spawn_timer: float = 0.0
@export var _spawn_interval: float = 0.05

func _ready() -> void:
	#calculate_random_obstacle_position()
	#create_random_obstacle()
	pass
	


func _physics_process(delta: float) -> void:
	_spawn_timer += delta
	if _spawn_timer > _spawn_interval:
		spawn_random_obstacle()
		_spawn_timer = 0.0


func spawn_random_obstacle():
	var meteor_instance: Meteor = _meteor_scene.instantiate()
	add_child(meteor_instance)
	meteor_instance.global_position = _calculate_random_position()
	meteor_instance.calculate_linear_velocity()


func _calculate_random_position() -> Vector2:
	var camera_position: Vector2 = get_viewport().get_camera_2d().global_position
	var screen_size: Vector2 = get_window().size
	var spawn_at_bottom_or_top_edge = randi_range(0, 1)
	var x_spawn_position: int = 0
	var y_spawn_position: int = 0
	
	if spawn_at_bottom_or_top_edge:
		x_spawn_position = randi_range(
			int(camera_position.x - screen_size.x * 2),
			int(camera_position.x + screen_size.x * 2)
		)
		y_spawn_position = camera_position.y + screen_size.y * 2 * [-1, 1].pick_random()
	else:
		x_spawn_position = camera_position.x + screen_size.x * 2 * [-1, 1].pick_random()
		y_spawn_position = randi_range(
			int(camera_position.y - screen_size.y * 2),
			int(camera_position.y + screen_size.y * 2)
		)
	
	return Vector2(x_spawn_position, y_spawn_position)
