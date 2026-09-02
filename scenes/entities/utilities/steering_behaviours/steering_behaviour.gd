class_name SteeringBehaviour extends Node

var source_global_position: Vector2
var target_positions: Array[Vector2]
var interest_map: Dictionary[Vector2, float]
var danger_map: Dictionary[Vector2, float]

func _init() -> void:
	pass

func calculate_maps(targets: Array[Vector2], interest_map: Array[Vector2], danger_map: Array[Vector2]):
	pass


func chase():
	Raycaster
