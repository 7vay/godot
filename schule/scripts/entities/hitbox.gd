extends Area2D

class_name HitBox

signal on_damage
	
func damage(damage: int):
	on_damage.emit(damage)

func isSelected():
	pass
	# connect to mouse enter signal
