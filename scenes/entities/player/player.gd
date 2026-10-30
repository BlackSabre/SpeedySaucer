class_name Player extends RigidBody2D

@export var input_component: InputComponent
@export var player_movement_component: PlayerMovementComponent
@export var weapon_aim_component: WeaponAimComponent

@onready var collisionShape2D = $CollisionShape2D
@onready var circleShape2D: CircleShape2D = $CollisionShape2D.shape
@onready var weapon_pivot_point: Node2D = $WeaponPivotPoint


func _process(_delta) -> void:
	aim_weapon()


func _physics_process(_delta) -> void:
	move()
	
	

func get_saucer_edge_points(sample_count : int = 8) -> Array[Vector2]:
	var points: Array[Vector2] = []
	
	if (not(circleShape2D is CircleShape2D)):
		printerr("Shape is not a circle!")
		return []
		
	var radius = circleShape2D.radius
	var angle_step = TAU / sample_count
	
	for i in range(sample_count):
		var angle = i * angle_step
		var offset = Vector2(cos(angle), sin(angle)) * radius
		var world_point = global_position + offset.rotated(global_rotation)
		points.append(world_point)
	
	return points


func move() -> void:
	var vector_force: Vector2 = input_component.calculate_vector_force()
	player_movement_component.apply_movement(self, vector_force)


func aim_weapon():
	var aim_vector = input_component.get_direction_to_mouse_pointer(self)
	weapon_aim_component.aim_weapon(aim_vector, weapon_pivot_point)
	
