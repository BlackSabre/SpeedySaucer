class_name HealthComponent extends Node

@export var max_health: int = 100

@onready var current_health: int = max_health

signal on_died

func heal(amount: int):
	current_health = min(current_health + amount, max_health)


func damage(amount: int):
	current_health = max(current_health - amount, 0)
	if current_health == 0:
		on_died.emit()
