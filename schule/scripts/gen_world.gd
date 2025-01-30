extends Node2D 

@export var noiseHeight : NoiseTexture2D #das ist der "generator" des Noise
@export var noiseBiome : NoiseTexture2D #Biome

var noise : Noise
var noiseB : Noise

@onready var tileMap = $TileMap # importieren der Sprites
@onready var camera = $Player/Camera2D

var renderDistance = 10
var tileSize = 16
var lastPositionCamera = Vector2.ZERO

#SOURCE IDS
var sourceIdWater = 0 
var sourceIdGras = 1
var sourceIdSand = 2
var sourceIdMagic = 3
var sourceIdIce = 4
var sourceIdHills = 5

#ATLAS
var hillsTreppeAtlas = Vector2i(9,4)
var waterAtlas = Vector2i(0,0) #position des Wassers auf dem Spritesheet
var grasAtlas = Vector2i(1,1)

#LAYER
var waterLayer = 0
var sandLayer = 1
var grasLayer = 2
var magicLayer = 3
var iceLayer = 4
var hillsLayer = 5

#TERRAIN
var terrainGrasInt = 0
var terrainSandInt = 1
var terrainIceInt = 2
var terrainMagicInt = 3
var terrainHillsInt = 4
var terrainNumbers = 5

#TILES ARR
var TerrainArr = [] 
# gras = 0
# sand = 1
# ice = 2
# magic = 3 
# hills = 4


func _ready():
	noise = noiseHeight.noise #gibt das Generierte Noise in eine Variable über
	noiseB = noiseBiome.noise
	for x in range(0,terrainNumbers):
		TerrainArr.append([])
	update_world()


func update_world():
	
	var cameraPosition = camera.global_position
	var viewportSize = Vector2(get_viewport().size) / camera.zoom  # Sichtbereich anpassen an Zoom
	var min_x = int((cameraPosition.x - viewportSize.x / 2) / tileSize) - renderDistance
	var max_x = int((cameraPosition.x + viewportSize.x / 2) / tileSize) + renderDistance
	var min_y = int((cameraPosition.y - viewportSize.y / 2) / tileSize) - renderDistance
	var max_y = int((cameraPosition.y + viewportSize.y / 2) / tileSize) + renderDistance
	
	TerrainArr.clear()  
	for i in range(6):
		TerrainArr.append([])
	
	for x in range(min_x , max_x + renderDistance):
		for y in range(min_y , max_y + renderDistance):
			var noise_val : float = noise.get_noise_2d(x,y)
			var noise_val_Biome : float = noiseB.get_noise_2d(x,y)
			var pos = Vector2i(x,y)
			var tileDa = false
			var newTerrain = -1
			var newTerrainGras = -1
			var newTerrainSand = -1
			
			if noise_val >= 0.4:
				newTerrain = terrainHillsInt
			if noise_val >= -0.05:
				newTerrainSand = terrainSandInt
				if noise_val_Biome >= 0.12:
					if noise_val_Biome >= 0.19:
						newTerrain = terrainMagicInt
					newTerrainGras = terrainGrasInt
				elif noise_val_Biome <= -0.05:
					newTerrain = terrainIceInt
					
			if tileMap.get_cell_source_id(waterLayer, pos) != sourceIdWater:
				tileMap.set_cell(waterLayer ,pos , sourceIdWater, waterAtlas) #Wasser soll ja überhall hin also lassen packen wir dasl "drunter"
			
			if newTerrain != -1 || newTerrainGras != -1 || newTerrainSand != -1:
				var pruefendeLayer = [grasLayer, iceLayer, magicLayer, sandLayer, hillsLayer]
				for layer in pruefendeLayer: 
					if tileMap.get_cell_source_id(layer, pos) != -1:
						tileDa = true
						break;
				if !tileDa: 
					TerrainArr[newTerrain].append(pos)
					TerrainArr[newTerrainGras].append(pos)
					TerrainArr[newTerrainSand].append(pos)
			
	tileMap.set_cells_terrain_connect(grasLayer, TerrainArr[0], terrainGrasInt, 0)
	tileMap.set_cells_terrain_connect(iceLayer, TerrainArr[2], terrainIceInt, 0)
	tileMap.set_cells_terrain_connect(magicLayer, TerrainArr[3], terrainMagicInt, 0)
	tileMap.set_cells_terrain_connect(sandLayer, TerrainArr[1], terrainSandInt, 0)
	tileMap.set_cells_terrain_connect(hillsLayer, TerrainArr[4], terrainHillsInt, 0)
	
func _physics_process(_delta):
	var cameraPosition = camera.global_position
	if cameraPosition.distance_to(lastPositionCamera) > tileSize:
		update_world()
		lastPositionCamera = cameraPosition  # Position updaten
