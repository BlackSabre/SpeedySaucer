class_name ExplosionParticles extends Node2D

@export var particles: GPUParticles2D

var _particle_process_material: ParticleProcessMaterial

func _ready() -> void:
	particles.finished.connect(delete_particle)
	_particle_process_material = particles.process_material


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("move_up"):
		play(Vector2(10, 10))


func play(direction: Vector2):
	if not _particle_process_material:
		printerr("No particle process material in particle")
		return
	
	_particle_process_material.emission_shape_offset = Vector3(direction.x, direction. y, 0)
	particles.emitting = true


func delete_particle(direction: Vector2):
	queue_free()
		
	
