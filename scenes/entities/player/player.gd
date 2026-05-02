extends RigidBody2D

@onready var collisionShape2D = $CollisionShape2D
@onready var circleShape2D: CircleShape2D = $CollisionShape2D.shape
var force = 1000;



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(_delta) -> void:
	aim_weapon()


func _physics_process(_delta) -> void:
	apply_movement()
	


func _unhandled_input(_event: InputEvent) -> void:
	#if event.is_action_pressed("move_up"):
		#apply_force(Vector2(0, -force))
	pass
	


func apply_movement():
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var vector_force: Vector2 = input_vector * force;	
	apply_force(vector_force)

	
func get_saucer_edge_points(sample_count : int = 8) -> Array[Vector2]:
	var points: Array[Vector2] = []
	
	if (not(circleShape2D is CircleShape2D)):
		print("not a circle")
		return []
		
	var radius = circleShape2D.radius
	var angle_step = TAU / sample_count # TAU = 2π
	
	for i in range(sample_count):
		var angle = i * angle_step
		var offset = Vector2(cos(angle), sin(angle)) * radius
		var world_point = global_position + offset.rotated(global_rotation)
		points.append(world_point)		
	
	return points


func aim_weapon():
	var weapon = $WeaponPivotPoint
	var aim_vector = global_position.direction_to(get_global_mouse_position())
	var aim_position = weapon.global_position + aim_vector
	weapon.look_at(aim_position)
	
