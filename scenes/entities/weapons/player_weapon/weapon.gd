extends Node2D
class_name Weapon

@onready var projectile_marker: Marker2D = $ProjectileSpawnPosition
@onready var projectile_scene: PackedScene = preload("uid://cb182f731msqr")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and	event.pressed:
		get_viewport().set_input_as_handled()
		fire(get_global_mouse_position());


func fire(mouse_position: Vector2) -> void:
	GlobalSignals.weapon_fired.emit(mouse_position, projectile_marker.global_position, Enums.ProjectileSource.PLAYER)	
