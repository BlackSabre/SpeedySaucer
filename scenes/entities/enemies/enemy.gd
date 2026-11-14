class_name Enemy extends CharacterBody2D

@export var _projectile_parent: Node
@export var _alignment_to_player_firing_threshold: float = 0.96
@export var _push_force: float = 200.0
@export var _target_finder_component: TargetFinderComponent
@export var _movement_component: MovementComponent
@export var _health_component: HealthComponent
@export var _hurtbox: HurtBox

@onready var _enemy_weapon: EnemyWeapon = %EnemyWeapon

var target_player: RigidBody2D
var target_global_positions: Array[Vector2]
var direction_to_player: Vector2


func _ready() -> void:
	target_player = get_tree().get_first_node_in_group("Players")
	_hurtbox.on_hurtbox_hit.connect(_on_hurtbox_hit)
	
	if target_player:
		look_at(target_player.global_position)


func _physics_process(_delta: float) -> void:
	target_global_positions = _find_next_target()
	velocity = _movement_component.move_towards(target_player, target_global_positions[0])
	
	fire()
	move_and_slide()
	apply_forces()


func fire():
	direction_to_player = (target_player.global_position - global_position).normalized()
	var normalized_current_direction: Vector2 = _movement_component.get_normalized_current_direction()
	var direction_player_alignment: float = direction_to_player.dot(normalized_current_direction)
	if direction_player_alignment > _alignment_to_player_firing_threshold:
		_enemy_weapon.fire_weapon(normalized_current_direction, _projectile_parent, Enums.ObjectSources.ENEMY)


func apply_forces() -> void:
	for i: int in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			collision.get_collider().apply_impulse(-collision.get_normal() * _push_force)
		

# Returns the player global position if ahead of the enemy, otherwise returns a random
# global_position. Does not currently support having multiple targets
func _find_next_target() -> Array[Vector2]:
	var normalized_current_direction: Vector2 = _movement_component.get_normalized_current_direction()
	return _target_finder_component.find_next_target_position(normalized_current_direction)


func _on_hurtbox_hit(hitbox: Hitbox, damage: int):
	print("hurtbox has been hit with damage ", damage)
	_health_component.damage(damage)
	print(_health_component.current_health)
	pass



func take_damage(damage: int, damage_source: Enums.ObjectSources):
	if damage_source != Enums.ObjectSources.ENEMY:
		_health_component.damage(damage)
		print(_health_component.current_health)
		print("Enemy take damagedsadsadas")
