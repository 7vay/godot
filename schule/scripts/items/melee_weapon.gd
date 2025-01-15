extends Item

class_name MeleeWeapon

@export var damage = 4

func on_interaction():
	pass

func on_hit(player: Player):
	if player.animation_player.is_playing(): return	
	
	player.animation_player.play("swing")
	
	var areas = player.hurtbox.get_overlapping_areas()
	if areas == null: return
	
	for area in areas:
		if area is HitBox:
			area.damage(damage)
