extends CharacterBody2D

@export var enemy_weapon: EnemyWeapon
@export var projectile_parent: Node
@export var alignment_to_player_firing_threshold: float = 0.96
@export var push_force: float = 200.0

@export var _target_finder_component: TargetFinderComponent
@export var _movement_component: MovementComponent

var normalized_current_direction := Vector2.LEFT
var normalized_previous_direction: Vector2
var patrol_timer: float = 0.0
var patrol_timer_max: float = 5.0
var target_player: RigidBody2D
var target_global_positions: Array[Vector2]
var direction_to_player: Vector2


func _ready() -> void:
	target_player = get_tree().get_first_node_in_group("Players")
	
	if target_player:
		look_at(target_player.global_position)


func _physics_process(_delta: float) -> void:
	target_global_positions = _find_next_target()
	velocity = _movement_component.move_towards(target_player, target_global_positions[0])
	
	fire()
	move_and_slide()
	apply_forces()


func fire():
	direction_to_player = target_player.global_position
	var direction_player_alignment: float = direction_to_player.dot(normalized_current_direction)
	if direction_player_alignment > alignment_to_player_firing_threshold:
		enemy_weapon.fire_weapon(normalized_current_direction, projectile_parent)


func apply_forces() -> void:
	for i: int in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			collision.get_collider().apply_impulse(-collision.get_normal() * push_force)
		
		

# Returns the player global position if ahead of the enemy, otherwise returns a random
# global_position. Does not currently support having multiple targets
func _find_next_target() -> Array[Vector2]:
	return _target_finder_component.find_next_target_position(normalized_current_direction)
