extends Node2D

@export var speed = 1000;

@onready var time_to_live_timer: Timer = $TimeToLiveTimer

var target_position: Vector2 = Vector2(45, 45)
var direction = Vector2(1, 0);
var projectile_source: Enums.ProjectileSource = Enums.ProjectileSource.PLAYER

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("bullet_pos: ", position)
	#prints("bullet_global_pos", global_position)
	time_to_live_timer.timeout.connect(_on_time_to_live_timer_timeout)
	pass

func _physics_process(delta: float) -> void:	
	global_position += direction * speed * delta
	#global_position = position + speed * direction * delta
	#print("proj pos")
	#print(global_position)
	pass

func setup(new_target_position: Vector2, spawn_position: Vector2, new_projectile_source: Enums.ProjectileSource):	
	projectile_source = new_projectile_source
	global_position = spawn_position
	direction = global_position.direction_to(new_target_position)


func _on_time_to_live_timer_timeout():
	queue_free()
