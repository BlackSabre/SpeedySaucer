class_name PlayerMovementComponent extends Node

func apply_movement(rigid_body: RigidBody2D, force: Vector2) -> void:
	rigid_body.apply_force(force)
