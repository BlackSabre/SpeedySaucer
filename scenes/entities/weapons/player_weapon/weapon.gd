class_name PlayerWeapon
extends Node2D

@export var projectile_scene: PackedScene

@onready var projectile_marker: Marker2D = $ProjectileSpawnPosition


func fire(mouse_position: Vector2, projectile_parent: Node) -> void:
	var projectile: Projectile = projectile_scene.instantiate()
	var target_direction: Vector2 = (mouse_position - projectile_marker.global_position).normalized()
	projectile.fire_projectile(projectile_marker.global_position, target_direction, projectile_parent, Enums.ObjectSources.PLAYER)
	
