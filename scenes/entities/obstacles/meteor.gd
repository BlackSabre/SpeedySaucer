extends RigidBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var sprite_material: Material
@onready var timer: Timer = $Timer

func _ready():
	sprite_material = sprite_2d.material
	timer.timeout.connect(outline_remove)
	outline_remove()

func outline_sprite():
	sprite_material.set_shader_parameter("outline_thickness", 7)
	if timer.time_left > 0:
		return
	timer.start()

func outline_remove():
	sprite_material.set_shader_parameter("outline_thickness", 0)
