extends Control


func _process(delta: float) -> void:
	pass


func _on_starten_button_pressed() -> void:
	print("Starten wurde gedrückt")
	#neue Welt wird generiert...


func _on_laden_button_pressed() -> void:
	print("Laden wurde gedrückt")
	#verschiedene gespeicherte Welten laden


func _on_optionen_button_pressed() -> void:
	print("Optionen wurde gedrückt")
	#Optionenfenster starten und einstellen

func _on_beenden_button_pressed() -> void:
	print("Beenden wurde gedrückt")
	#Projekt schließen
	
#Einstellungenfenster vielleicht noch mit Escape
