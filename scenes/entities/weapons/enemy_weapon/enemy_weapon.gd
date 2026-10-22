class_name EnemyWeapon extends Node2D

@export var projectile_scene: PackedScene
@export var projectile_spawn_positions: Array[Marker2D]
@export var fire_cooldown: float = 1.0


var _fire_timer: float = 0.0

func _physics_process(_delta: float) -> void:
	_fire_timer += _delta


func fire_weapon(direction: Vector2, parent: Node) -> bool:
	if _fire_timer < fire_cooldown:
		return false
	
	spawn_projectile(projectile_spawn_positions[0].global_position, direction, parent)
	_fire_timer = 0.0
	return true


func spawn_projectile(spawn_global_position: Vector2, direction: Vector2, parent: Node) -> void:
	var projectile_instance: Projectile = projectile_scene.instantiate()
	parent.add_child(projectile_instance)
	projectile_instance.setup_direction(spawn_global_position, direction)
	projectile_instance.global_position = spawn_global_position
