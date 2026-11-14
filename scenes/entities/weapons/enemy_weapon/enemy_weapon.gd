class_name EnemyWeapon extends Node2D

@export var fire_cooldown: float = 1.0
@export var projectile_scene: PackedScene
@export var projectile_spawn_positions: Array[Marker2D]

var _fire_timer: float = 0.0
var _last_projectile_spawn_index: int = 0


func _physics_process(_delta: float) -> void:
	_fire_timer += _delta


func fire_weapon(direction: Vector2, projectile_parent: Node, source: Enums.ObjectSources) -> bool:
	if _fire_timer < fire_cooldown:
		return false
	
	var spawn_global_position: Vector2 = _calculate_next_spawn_position()
	var projectile_instance: Projectile = projectile_scene.instantiate()
	projectile_instance.fire_projectile(spawn_global_position, direction, projectile_parent, 
		source)
	_fire_timer = 0.0
	return true


func _calculate_next_spawn_position() -> Vector2:
	if projectile_spawn_positions.size() == 0:
		push_error("No projectiles spawn positions have been set")
		return Vector2.ZERO
	
	var next_index: int = (_last_projectile_spawn_index + 1) % projectile_spawn_positions.size()
	_last_projectile_spawn_index = next_index
	return projectile_spawn_positions[next_index].global_position
	
