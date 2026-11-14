class_name Player extends RigidBody2D

@export var _projectile_parent: Node
@export var _input_component: InputComponent
@export var _player_movement_component: PlayerMovementComponent
@export var _weapon_aim_component: WeaponAimComponent
@export var _health_component: HealthComponent
@export var _hurtbox: HurtBox

@onready var _circle_shape_2d: CircleShape2D = $CollisionShape2D.shape
@onready var _weapon_pivot_point: Node2D = $WeaponPivotPoint
@onready var _weapon: PlayerWeapon = %Weapon


func _ready():
	_input_component.left_mouse_clicked.connect(_on_left_mouse_clicked)
	_hurtbox.on_hurtbox_hit.connect(_on_hurtbox_hit)


func _process(_delta) -> void:
	aim_weapon()


func _physics_process(_delta) -> void:
	move()
	
	

func get_saucer_edge_points(sample_count : int = 8) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var radius = _circle_shape_2d.radius
	var angle_step = TAU / sample_count
	
	for i in range(sample_count):
		var angle = i * angle_step
		var offset = Vector2(cos(angle), sin(angle)) * radius
		var world_point = global_position + offset.rotated(global_rotation)
		points.append(world_point)
	
	return points


func move() -> void:
	var vector_force: Vector2 = _input_component.calculate_vector_force()
	_player_movement_component.apply_movement(self, vector_force)


func aim_weapon():
	var aim_vector = _input_component.get_direction_to_mouse_pointer(self)
	_weapon_aim_component.aim_weapon(aim_vector, _weapon_pivot_point)


func take_damage(amount: int, damage_source: Enums.ObjectSources):
	if damage_source != Enums.ObjectSources.PLAYER:
		_health_component.damage(amount)
		print(_health_component.current_health)


func _on_left_mouse_clicked(mouse_position: Vector2):
	_weapon.fire(mouse_position, _projectile_parent)


func _on_hurtbox_hit(hitbox: Hitbox, damage: int):
	_health_component.damage(damage)
