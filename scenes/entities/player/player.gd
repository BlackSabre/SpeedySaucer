class_name Player extends RigidBody2D

@onready var collisionShape2D = $CollisionShape2D
@onready var circleShape2D: CircleShape2D = $CollisionShape2D.shape
@onready var weapon_pivot_point: Node2D = $WeaponPivotPoint


signal on_player_weapon_fired


var movement_force: float = 1000.0;


func _process(_delta) -> void:
	aim_weapon()


func _physics_process(_delta) -> void:
	apply_movement()
	

func apply_movement():
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var vector_force: Vector2 = input_vector * movement_force;
	apply_force(vector_force)

	
func get_saucer_edge_points(sample_count : int = 8) -> Array[Vector2]:
	var points: Array[Vector2] = []
	
	if (not(circleShape2D is CircleShape2D)):
		print("not a circle")
		return []
		
	var radius = circleShape2D.radius
	var angle_step = TAU / sample_count
	
	for i in range(sample_count):
		var angle = i * angle_step
		var offset = Vector2(cos(angle), sin(angle)) * radius
		var world_point = global_position + offset.rotated(global_rotation)
		points.append(world_point)
	
	return points


func aim_weapon():
	var aim_vector = global_position.direction_to(get_global_mouse_position())
	var aim_position = weapon_pivot_point.global_position + aim_vector
	weapon_pivot_point.look_at(aim_position)
	
