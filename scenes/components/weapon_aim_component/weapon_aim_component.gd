class_name WeaponAimComponent extends Node


func aim_weapon(aim_vector: Vector2, weapon_pivot_point: Node2D):
	var aim_position = weapon_pivot_point.global_position + aim_vector
	weapon_pivot_point.look_at(aim_position)
