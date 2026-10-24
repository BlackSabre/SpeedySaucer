class_name Meteor extends RigidBody2D

@export var move_speed_base: int = 350

@export var move_speed_max_offset: int = 200
@export var debug_outline_thickness: float = 7

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

var sprite_material: Material

var current_direction: Vector2

func _ready():
	sprite_material = sprite_2d.material
	timer.timeout.connect(outline_remove)
	outline_remove()
	
	var random_speed_offset: int = randi_range(0, move_speed_max_offset)
	linear_velocity = _calculate_direction_towards_player() * (move_speed_base + random_speed_offset)


var threshold: int = 1000
func _calculate_direction_towards_player() -> Vector2:
	var player: Player = get_tree().get_first_node_in_group("Players")
	
	if not player: 
		return Vector2.ZERO
	
	var player_global_position: Vector2 = player.global_position
	var position_near_player: Vector2 = player_global_position + Vector2(randi_range(-threshold, threshold), randi_range(-threshold, threshold))	
	var direction: Vector2 = (position_near_player - global_position).normalized()
	return direction


func outline_sprite():
	sprite_material.set_shader_parameter("outline_thickness", debug_outline_thickness)
	if timer.time_left > 0:
		return
	timer.start()


func outline_remove():
	sprite_material.set_shader_parameter("outline_thickness", 0)
