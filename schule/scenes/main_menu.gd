extends Control

func _on_starten_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_laden_pressed() -> void:
	print("Hilfe Laden")


func _on_beenden_pressed() -> void:
	get_tree().quit()
