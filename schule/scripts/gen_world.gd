extends Node2D 

@export var noiseHeight : NoiseTexture2D #das ist der "generator" des Noise
@export var noiseBiome : NoiseTexture2D #Biome
var noise : Noise
var noiseB : Noise

var width : int = 200
var height : int = 200
@onready var tileMap = $TileMap # importieren der Sprites

#SOURCE IDS
var sourceIdWater = 0 
var sourceIdGras = 1
var sourceIdHills = 2
var sourceIdMagic = 3
var sourceIdMagicHills = 4
var sourceIdIce = 5
var sourceIdIceHills = 6

#ATLAS
var hillsTreppeAtlas = Vector2i(9,4)
var waterAtlas = Vector2i(0,0) #position des Wassers auf dem Spritesheet
var grasAtlas = Vector2i(1,1)

#LAYER
var waterLayer = 0
var grasLayer = 1
var sandLayer = 2
var magicLayer = 3
var iceLayer = 4
var hillsLayer = 5

#TERRAIN
var terrainGrasInt = 0
var terrainSandInt = 1
var terrainMagicInt = 2
var terrainIceInt = 3
var terrainNumbers = 4

#TILES ARR
var TerrainArr = [] 
# gras = 0
#sand = 1
# ice = 2
# magic = 3 


func _ready():
	noise = noiseHeight.noise #gibt das Generierte Noise in eine Variable über
	noiseB = noiseBiome.noise
	for x in range(0,terrainNumbers):
		TerrainArr.append([])
	generate_world()


func generate_world():
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			var noise_val : float = noise.get_noise_2d(x,y)
			var noise_val_Biome : float = noiseB.get_noise_2d(x,y)
			
			if noise_val >= 0.05:
				TerrainArr[0].append(Vector2i(x,y))
				if noise_val_Biome >= 0.12:
					if noise_val_Biome >= 0.19:
						TerrainArr[3].append(Vector2i(x,y))
					TerrainArr[1].append(Vector2i(x,y))
				elif noise_val_Biome <= -0.05:
					TerrainArr[2].append(Vector2i(x,y))
				
			#if noise_val >= 0.15:
			#	print("je")
			#	TerrainArr[3].append(Vector2i(x,y))
			#	if noise_val_Biome >= 0.12:
			#		TerrainArr[4].append(Vector2i(x,y))
			#	elif noise_val_Biome <= -0.05:
			#		TerrainArr[5].append(Vector2i(x,y))
					
					
				
			tileMap.set_cell(waterLayer ,Vector2(x,y), sourceIdWater, waterAtlas) #Wasser soll ja überhall hin also lassen packen wir dasl "drunter"
	#print(TerrainArr[3])
	tileMap.set_cells_terrain_connect(grasLayer, TerrainArr[0], terrainGrasInt, 0)
	tileMap.set_cells_terrain_connect(iceLayer, TerrainArr[2], terrainIceInt, 0)
	tileMap.set_cells_terrain_connect(magicLayer, TerrainArr[3], terrainMagicInt, 0)
	tileMap.set_cells_terrain_connect(sandLayer, TerrainArr[1], terrainSandInt, 0)
	#tileMap.set_cells_terrain_connect(hillsLayer, TerrainArr[3], terrainHillsInt, 0, 0)
	#tileMap.set_cells_terrain_connect(hillsLayer, TerrainArr[4], terrainHillsInt, 1, 0)
	#tileMap.set_cells_terrain_connect(hillsLayer, TerrainArr[5], terrainMagicHillsInt, 0)
	
