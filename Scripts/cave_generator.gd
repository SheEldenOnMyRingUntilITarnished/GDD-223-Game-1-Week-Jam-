extends Node2D

#
const COPPER_ORE_RARITY: float = 1
const IRON_ORE_RARITY: float = 3
const SILVER_ORE_RARITY: float = 5
const GOLD_ORE_RARITY: float = 8
const DIAMOND_RARITY: float = 12

#CAVE GENERATION---
const WIDTH: int = 60
const HEIGHT: int = 600
const HEIGHT_OF_WIN_ROOM: int = 30
const THICKNESS_OF_BORDERS: int = 12
const CELL_SIZE: float = 10.0
const CAVE_SMOOTHING: int = 4


#BLOCKS
const BACKGROUND_BLOCK = preload("res://Prefabs/Blocks/background_block_prefab.tscn")
const STONE_BLOCK = preload("res://Prefabs/Blocks/stone_block.tscn")
const COPPER_ORE_BLOCK = preload("res://Prefabs/Blocks/copper_block_prefab.tscn")
const IRON_ORE_BLOCK = preload("res://Prefabs/Blocks/iron_ore_block_prefab.tscn")
const SILVER_ORE_BLOCK = preload("res://Prefabs/Blocks/silver_block_prefab.tscn")
const GOLD_ORE_BLOCK = preload("res://Prefabs/Blocks/gold_block_prefab.tscn")
const DIAMOND_BLOCK = preload("res://Prefabs/Blocks/diamond_block.tscn")
const BEDROCK_BLOCK = preload("res://Prefabs/Blocks/bedrock_block_prefab.tscn")

var grid = []



func _ready():
	randomize()
	initalize_grid()
	generate_cave()
	draw_cave()


func initalize_grid():
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT - HEIGHT_OF_WIN_ROOM):
			grid[x].append(randf() > 0.45)
		for y in range(HEIGHT_OF_WIN_ROOM):
			grid[x].append(false)

func generate_cave():
	for i in range(CAVE_SMOOTHING):
		var new_grid = grid.duplicate(true)
		for x in range(WIDTH):
			for y in range(HEIGHT):
				var wall_count = count_neighboring_walls(x, y)
				if grid[x][y]:
					new_grid[x][y] = wall_count > 3
				else:
					new_grid[x][y] = wall_count > 4
		grid = new_grid

func count_neighboring_walls(x, y):
	var count = 0
	for i in range(-1, 2):
		for j in range(-1, 2):
			if i == 0 and j == 0:
				continue
			var nx = x + i
			var ny = y + j
			if nx < 0 or nx >= WIDTH or ny < 0 or ny >= HEIGHT:
				count += 1
			elif grid[nx][ny]:
				count += 1
	return count
	
func draw_cave():
	for x in range(THICKNESS_OF_BORDERS):
		for y in range(HEIGHT + THICKNESS_OF_BORDERS + THICKNESS_OF_BORDERS):
			var cell = BEDROCK_BLOCK.instantiate()
			cell.position = Vector2(-x * CELL_SIZE, y * CELL_SIZE)
			add_child(cell) 
		
	for x in range(THICKNESS_OF_BORDERS):
		for y in range(HEIGHT + THICKNESS_OF_BORDERS):
			var cell = BEDROCK_BLOCK.instantiate()
			cell.position = Vector2((x + WIDTH) * CELL_SIZE, y * CELL_SIZE)
			add_child(cell) 
	
	for x in range(WIDTH):
		for y in range(THICKNESS_OF_BORDERS):
			var cell = BEDROCK_BLOCK.instantiate()
			cell.position = Vector2(x * CELL_SIZE, (y + HEIGHT) * CELL_SIZE)
			add_child(cell) 
		
	for x in range(WIDTH):
		for y in range(HEIGHT):
			if grid[x][y]:
				if(randf() * HEIGHT > (randf() * DIAMOND_RARITY + 1) * (HEIGHT - y)):
					var cell = DIAMOND_BLOCK.instantiate()
					cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
					add_child(cell) 
				else:if(randf() * HEIGHT > (randf() * GOLD_ORE_RARITY + 1) * (HEIGHT - y)):
					var cell = GOLD_ORE_BLOCK.instantiate()
					cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
					add_child(cell) 
				else:if(randf() * HEIGHT > (randf() * SILVER_ORE_RARITY + 1) * (HEIGHT - y)):
					var cell = SILVER_ORE_BLOCK.instantiate()
					cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
					add_child(cell) 
				else:if(randf() * HEIGHT > (randf() * IRON_ORE_RARITY + 1) * (HEIGHT - y)):
					var cell = IRON_ORE_BLOCK.instantiate()
					cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
					add_child(cell) 
				else:if(randf() * HEIGHT > (randf() * COPPER_ORE_RARITY + 1) * (HEIGHT - y)):
					var cell = COPPER_ORE_BLOCK.instantiate()
					cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
					add_child(cell) 
				else:
					var cell = STONE_BLOCK.instantiate()
					cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
					add_child(cell) 
			else:
				var cell = BACKGROUND_BLOCK.instantiate()
				cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
				add_child(cell) 
			
