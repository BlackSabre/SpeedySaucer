extends Node2D
class_name Weapon

#@onready var weapon_sprite: Sprite2D = $Weapon
@onready var projectile_marker: Marker2D = $ProjectileSpawnPosition
@onready var projectile_scene: PackedScene = preload("uid://mvh0g7obdpyp")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and	event.pressed:
		get_viewport().set_input_as_handled()		
		fire(get_global_mouse_position());


func _process(_delta: float) -> void:
	#offset = Vector2(91, 91)
	#$/root/Player/Pivot.rotation += rotation_speed * delta
	#var pos = get_local_mouse_position() - position
	#look_at(get_global_mouse_position())
	pass


func fire(mouse_position: Vector2) -> void:
	#print("firing")
	#print("projectile_marker global: ", projectile_marker.global_position)
	#print("projectile_marker position: ", projectile_marker.position)
	
	GlobalSignals.weapon_fired.emit(mouse_position, projectile_marker.global_position, Enums.ProjectileSource.PLAYER)
	
	#GlobalSignals.weapon_fired.emit(projectile_pos.global_position)
	#print("firing")
	#print("projectile_pos: ", projectile_pos.global_position)
	#GlobalSignals.weapon_fired.emit(projectile_pos.global_position)
	
	#var projectile = projectile_scene.instantiate()
	#print(projectile_pos.position.x)
	
	#projectile.global_transform = projectile_pos.global_transform	
	#projectile.global_position.x += 100#projectile_pos.position.x + self.offset.x;
	#get_tree().root.add_child(projectile)
	
