class_name Hitbox extends Area2D

#signal hit_hurtbox(hurtbox: HurtBox)

var _hit_source: Enums.ObjectSources
var hit_source: Enums.ObjectSources:
	set(value):
		_hit_source = value
	get():
		return _hit_source


var _damage: int
var damage: int:
	set(value):
		_damage = value
	get():
		return _damage


#func register_hurtbox_hit(hurtbox: HurtBox, parent: Node):
	#print("register hurtbox hitaw")
	#hit_hurtbox.emit(hurtbox, hit_source)
	#
