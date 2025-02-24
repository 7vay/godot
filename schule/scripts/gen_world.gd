extends Node2D 

@export var noiseHeight : NoiseTexture2D # Generator für Terrain-Noise
@export var noiseBiome : NoiseTexture2D  # Generator für Biome

var noise : Noise
var noiseB : Noise

@onready var tileMap = $TileMap  # Deine TileMap
@onready var camera = $Player/Camera2D

var renderDistance = 10
var tileSize = 16
var lastPositionCamera = Vector2.ZERO

#CHUNK-SETTINGS 
var CHUNK_SIZE = 10
var loaded_chunks = {} 

#SOURCE IDS 
var sourceIdWater = 0 
var sourceIdGras = 1
var sourceIdSand = 2
var sourceIdMagic = 3
var sourceIdIce = 4
var sourceIdHills = 5

#ATLAS
var hillsTreppeAtlas = Vector2i(9,4)
var waterAtlas = Vector2i(0,0)
var grasAtlas = Vector2i(1,1)

#LAYER
var waterLayer = 0
var sandLayer = 1
var grasLayer = 2
var magicLayer = 3
var iceLayer = 4
var hillsLayer = 5

#TERRAIN-IDs
var terrainGrasInt = 0
var terrainSandInt = 1
var terrainMagicInt = 2
var terrainIceInt = 3
var terrainHillsInt = 4
var terrainNumbers = 5

#CHANCES
enum Biome {GRAS, ICE, MAGIC, SAND}
var biomeData = {
	Biome.ICE: {"tree": 0.08, "stone": 0.02, "treeSide": 0.005, "bush": 0.01, "ore": 0.02, "snow": 0.03},
	Biome.GRAS: {"tree": 0.05, "stone": 0.05, "treeSide": 0.01, "bush": 0.04, "berryTree": 0.02, "flower": 0.1, "mushroom": 0.04, "leaf": 0.3, "log": 0.03},
	Biome.MAGIC: {"tree": 0.4, "stone": 0.05, "treeSide": 0.005, "bush": 0.04, "berryTree": 0.02, "leaf": 0.2, "ore": 0.04, "log": 0.01},
	Biome.SAND: {"tree": 0.05, "stone": 0.2, "flower": 0.05, "kaktus": 0.07 }
}

func _ready():
	noise = noiseHeight.noise
	noiseB = noiseBiome.noise
	update_world()

func update_world():
	var cameraPosition = camera.global_position
	var viewportSize = Vector2(get_viewport().size) / camera.zoom  
	
	var min_x = int((cameraPosition.x - viewportSize.x / 2) / tileSize) - renderDistance
	var max_x = int((cameraPosition.x + viewportSize.x / 2) / tileSize) + renderDistance
	var min_y = int((cameraPosition.y - viewportSize.y / 2) / tileSize) - renderDistance
	var max_y = int((cameraPosition.y + viewportSize.y / 2) / tileSize) + renderDistance
	
	var min_chunk_x = int(floor(min_x / CHUNK_SIZE))
	var max_chunk_x = int(floor(max_x / CHUNK_SIZE))
	var min_chunk_y = int(floor(min_y / CHUNK_SIZE))
	var max_chunk_y = int(floor(max_y / CHUNK_SIZE))
	
	for cx in range(min_chunk_x, max_chunk_x + 1):
		for cy in range(min_chunk_y, max_chunk_y + 1):
			var chunk_key = str(cx) + "_" + str(cy)
			if not loaded_chunks.has(chunk_key):
				if load_chunk(cx, cy) == false:
					generate_chunk(cx, cy)

func generate_chunk(chunk_x: int, chunk_y: int) -> void:
	var chunk_key = str(chunk_x) + "_" + str(chunk_y)
	var chunk_data = {
		"gras": [],
		"sand": [],
		"ice": [],
		"magic": [],
		"hills": [],
		"trees": [],
		"stones": [],
	}
	
	for local_x in range(0, CHUNK_SIZE):
		for local_y in range(0, CHUNK_SIZE):
			var world_x = chunk_x * CHUNK_SIZE + local_x
			var world_y = chunk_y * CHUNK_SIZE + local_y
			var pos = Vector2i(world_x, world_y)
			var biome
			var BiomeProp
			
			var noise_val : float = noise.get_noise_2d(world_x, world_y)
			var noise_val_Biome : float = noiseB.get_noise_2d(world_x, world_y)
			
			var newTerrain = -1
			var newTerrainGras = -1
			var newTerrainSand = -1
			
			#if noise_val >= 0.4:
				#newTerrain = terrainHillsInt
			if noise_val >= -0.3:
				newTerrainSand = terrainSandInt
				if noise_val_Biome >= 0.2:
					if noise_val_Biome >= 0.25:
						newTerrain = terrainMagicInt
					newTerrainGras = terrainGrasInt
				elif noise_val_Biome <= 0.05:
					newTerrain = terrainIceInt
			
			tileMap.set_cell(waterLayer, pos, sourceIdWater, waterAtlas)
			
			if newTerrain != -1 or newTerrainGras != -1 or newTerrainSand != -1:
				if newTerrainGras != -1:
					chunk_data["gras"].append(pos)
					#BiomeProp = biomeData[Biome.Gras]
					#if randf() < BiomeProp["stone"]:
						#spawnStone(pos, "gras")
				if newTerrainSand != -1:
					chunk_data["sand"].append(pos)
					#BiomeProp = biomeData[Biome.SAND]
					#if randf() < BiomeProp["stone"]:
						#spawnStone(pos, "sand")
				if newTerrain == terrainHillsInt:
					chunk_data["hills"].append(pos)
				elif newTerrain == terrainMagicInt:
					chunk_data["magic"].append(pos)
					#BiomeProp = biomeData[Biome.MAGIC]
					#if randf() < BiomeProp["stone"]:
						#spawnStone(pos, "magic")
				elif newTerrain == terrainIceInt:
					BiomeProp = biomeData[Biome.ICE]
					biome = "ice"
					chunk_data[biome].append(pos)
					if randf() < BiomeProp["stone"]:
						spawnStone(pos, biome)
					elif randf() < BiomeProp["tree"]:
						spawnTree(pos, biome)
					elif randf() < BiomeProp["ore"]:
						spawnOre(pos, biome)
					elif randf() < BiomeProp["treeSide"]:
						spawnSideTree(pos, biome)
					elif randf() < BiomeProp["snow"]:
						spawnSnow(pos, biome)
					
					
			
	
	tileMap.set_cells_terrain_connect(grasLayer, chunk_data["gras"], terrainGrasInt, 0)
	tileMap.set_cells_terrain_connect(sandLayer, chunk_data["sand"], terrainSandInt, 0)
	#tileMap.set_cells_terrain_connect(hillsLayer, chunk_data["hills"], terrainHillsInt, 0)
	tileMap.set_cells_terrain_connect(magicLayer, chunk_data["magic"], terrainMagicInt, 0)
	tileMap.set_cells_terrain_connect(iceLayer, chunk_data["ice"], terrainIceInt, 0)
	
	
	
	loaded_chunks[chunk_key] = chunk_data
	
	save_chunk(chunk_x, chunk_y)


func save_chunk(chunk_x: int, chunk_y: int) -> void:
	var chunk_key = str(chunk_x) + "_" + str(chunk_y)
	if not loaded_chunks.has(chunk_key):
		return
	var chunk_data = loaded_chunks[chunk_key]
	
	var file_path = "res://saved/chunks/" + chunk_key + ".json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(chunk_data))
		file.close()


func load_chunk(chunk_x: int, chunk_y: int) -> bool:
	var chunk_key = str(chunk_x) + "_" + str(chunk_y)
	var file_path = "user://chunk_" + chunk_key + ".json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file.file_exists(file_path):
		return false
	if file:
		return false
	var data_str = file.get_as_text()
	file.close()
	var json = JSON.new()
	var chunk_data = json.parse(data_str)
	
	tileMap.set_cells_terrain_connect(grasLayer, chunk_data["grass"], terrainGrasInt, 0)
	tileMap.set_cells_terrain_connect(sandLayer, chunk_data["sand"], terrainSandInt, 0)
	tileMap.set_cells_terrain_connect(hillsLayer, chunk_data["hills"], terrainHillsInt, 0)
	tileMap.set_cells_terrain_connect(magicLayer, chunk_data["magic"], terrainMagicInt, 0)
	tileMap.set_cells_terrain_connect(iceLayer, chunk_data["ice"], terrainIceInt, 0)
	
	loaded_chunks[chunk_key] = chunk_data
	return true
	
func spawnStone(pos, biome):
	var stone = preload("res://Items/Rescources/IceBiome/stoneIce.tscn").instantiate()  
	stone.position = pos * tileSize
	add_child(stone)
	
func spawnTree(pos, biome):
	var tree = preload("res://Items/Rescources/IceBiome/treeIce.tscn").instantiate()
	tree.position = pos * tileSize
	add_child(tree)
	
func spawnOre(pos, biome):
	var ore = preload("res://Items/Rescources/IceBiome/Ore.tscn").instantiate()
	ore.position = pos * tileSize
	add_child(ore)
	
func spawnBush(pos, biome):
	var bush = preload("res://Items/Rescources/IceBiome/bush.tscn").instantiate()
	bush.position = pos * tileSize
	add_child(bush)
	
func spawnSnow(pos, biome):
	var snow = preload("res://Items/Rescources/IceBiome/snow.tscn").instantiate()
	snow.position = pos * tileSize
	add_child(snow)
	
func spawnSideTree(pos, biome):
	var tree = preload("res://Items/Rescources/IceBiome/treeSide.tscn").instantiate()
	tree.position = pos * tileSize
	add_child(tree)
	
func _physics_process(_delta):
	var cameraPosition = camera.global_position
	if cameraPosition.distance_to(lastPositionCamera) > tileSize:
		update_world()
		lastPositionCamera = cameraPosition
