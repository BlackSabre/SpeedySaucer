class_name Projectile extends Node2D

@export var speed = 1000;
@export var damage = 10
@export var _hitbox: Hitbox

@onready var time_to_live_timer: Timer = $TimeToLiveTimer



var target_position: Vector2 = Vector2(45, 45)
var direction = Vector2(1, 0);


func _ready() -> void:
	time_to_live_timer.timeout.connect(_on_time_to_live_timer_timeout)


func _physics_process(delta: float) -> void:	
	global_position += direction * speed * delta


func fire_projectile(spawn_global_position: Vector2, 
	normalized_direction: Vector2, 
	spawn_parent_node: Node,
	source: Enums.ObjectSources) -> void:
	
	spawn_parent_node.add_child(self)
	_hitbox.hit_source = source
	_hitbox.damage = damage
	global_position = spawn_global_position
	direction = normalized_direction


func _on_time_to_live_timer_timeout():
	queue_free()
