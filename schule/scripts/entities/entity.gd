extends CharacterBody2D

class_name Entity

@export var max_health: int
@export var speed: int

var health: int

func _ready(): 
	health = max_health

func kill():
	print("Character died")
	
func damage(damage: int):
	print(str("Health: ", health))
	health -= damage
	if health <= 0:
		kill()
