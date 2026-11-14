extends Node2D

@onready var maze: Area2D = $Maze
@onready var projectiles: Node = $Projectiles

var projectile_scene: PackedScene = preload("uid://cb182f731msqr")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	maze.connect("player_out_of_bounds", player_out_of_bounds)


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
