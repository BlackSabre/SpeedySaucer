extends Node2D

@onready var maze: Area2D = $Maze
@onready var projectiles: Node = $Projectiles

var projectile_scene: PackedScene = preload("uid://mvh0g7obdpyp")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	maze.connect("player_out_of_bounds", player_out_of_bounds)
	GlobalSignals.connect("weapon_fired", _on_weapon_fired)


func _on_maze_body_exited(_body: Node2D) -> void:
	#get_tree().reload_current_scene()
	#print("Exited")
	pass


func _on_maze_body_entered(_body: Node2D) -> void:
	#print("Entered")
	pass


func player_out_of_bounds() -> void:
	if is_inside_tree():
		get_tree().reload_current_scene()


func _on_weapon_fired(target_position: Vector2, spawn_position: Vector2, projectile_source: Enums.ProjectileSource):
	var projectile := projectile_scene.instantiate()
	projectiles.add_child(projectile)
	projectile.setup(target_position, spawn_position, projectile_source)
	#projectile.global_position = projectile_marker.global_position
