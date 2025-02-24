extends Control

func _on_starten_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_laden_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ladebildschirm.tscn")


func _on_beenden_pressed() -> void:
	get_tree().quit()
