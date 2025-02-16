extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_starten_button_pressed() -> void:
	print("Starten wurde gedrückt")


func _on_laden_button_pressed() -> void:
	print("Laden wurde gedrückt")


func _on_optionen_button_pressed() -> void:
	print("Optionen wurde gedrückt")


func _on_beenden_button_pressed() -> void:
	print("Beenden wurde gedrückt")
