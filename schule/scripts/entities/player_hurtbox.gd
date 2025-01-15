extends Area2D

func _process(delta: float) -> void:
	var angle = get_angle_to(get_global_mouse_position()) - 1.5
	rotate(angle)
