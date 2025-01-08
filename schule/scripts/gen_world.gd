extends Node2D 

@export var noiseHeight : NoiseTexture2D #das ist der "generator" des Noise
var noise : Noise

var width : int = 200
var height : int = 200
@onready var tileMap = $TileMap # importieren der Sprites

var sourceIdWater = 0 #wasser id
var waterAtlas = Vector2i(0,0) #position des Wassers auf dem Spritesheet
var sourceIdGras = 1
var grasAtlas = Vector2i(1,1) #erstmal random gras tile genomme   SPÄTER ÄNDEERUNG ZU TERRAIN

#LAYER
var waterLayer = 0
var grasLayer = 1

var grasTilesArr = []
var terrainGrasInt = 0

func _ready():
	noise = noiseHeight.noise #gibt das Generierte Noise in eine Variable über
	generate_world()


func generate_world():
	for x in range(-width/2, width/2):
		for y in range(-height/2, width/2):
			var noise_val : float = noise.get_noise_2d(x,y)
			if noise_val >= 0.0: #Land
				grasTilesArr.append(Vector2i(x,y))
				pass
				
			tileMap.set_cell(waterLayer ,Vector2(x,y), sourceIdWater, waterAtlas) #Wasser soll ja überhall hin also lassen packen wir dasl "drunter"
	tileMap.set_cells_terrain_connect(grasLayer, grasTilesArr, terrainGrasInt, 0)
