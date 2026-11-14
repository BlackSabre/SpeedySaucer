class_name HurtBox extends Area2D

@export var _source: Enums.ObjectSources

signal on_hurtbox_hit(hitbox: Hitbox, damage: int)

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(other_area: Area2D):
	if other_area is not Hitbox:
		return
	
	var hitbox: Hitbox = other_area
	if hitbox.hit_source != self._source:
		if other_area.damage == null:
			push_error("Other area does not have damage value.")
		on_hurtbox_hit.emit(hitbox, hitbox.damage)
