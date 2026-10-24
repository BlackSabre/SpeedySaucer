class_name Meteor extends RigidBody2D

@export var move_speed_base: int = 350

@export var move_speed_max_offset: int = 250
@export var debug_outline_thickness: float = 7

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var outline_timer: Timer = $OutlineTimer
@onready var despawn_timer: Timer = $DespawnTimer


var sprite_material: Material
var spawn_position_max_offset: int = 1000

func _ready():
	sprite_material = sprite_2d.material
	outline_timer.timeout.connect(_outline_remove)
	despawn_timer.timeout.connect(_despawn)
	_outline_remove()
	

func calculate_linear_velocity() -> void:
	var random_speed_offset: int = randi_range(-move_speed_max_offset, move_speed_max_offset)
	linear_velocity = _calculate_direction_towards_player() * (move_speed_base + random_speed_offset)


func _calculate_direction_towards_player() -> Vector2:
	var player: Player = get_tree().get_first_node_in_group("Players")
	
	if not player: 
		return Vector2.ZERO
	
	var player_global_position: Vector2 = player.global_position
	var position_near_player: Vector2 = player_global_position + Vector2(
		randi_range(-spawn_position_max_offset, spawn_position_max_offset), 
		randi_range(-spawn_position_max_offset, spawn_position_max_offset))
	var direction: Vector2 = (position_near_player - global_position).normalized()
	return direction


func outline_sprite():
	sprite_material.set_shader_parameter("outline_thickness", debug_outline_thickness)
	if outline_timer.time_left > 0:
		return
	outline_timer.start()


func _outline_remove():
	sprite_material.set_shader_parameter("outline_thickness", 0)


func _despawn():
	queue_free()
