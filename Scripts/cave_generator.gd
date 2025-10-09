extends Node2D

#ORE RARITY
const COPPER_ORE_RARITY: float = 1
const IRON_ORE_RARITY: float = 7
const SILVER_ORE_RARITY: float = 12
const GOLD_ORE_RARITY: float = 56
const DIAMOND_RARITY: float = 82

#CAVE GENERATION---
const WIDTH: float = 60
const HEIGHT_OF_FALL_AREA: float = 300
const AMOUNT_OF_SHOPS: float = 6
const SHOP_HEIGHT: float = 12
const HEIGHT_OF_CAVE: float = 1200
const HEIGHT_OF_WIN_ROOM: float = 30
const THICKNESS_OF_BORDERS: float = 12
const CELL_SIZE: float = 10.0
const CAVE_SMOOTHING: float = 4

#BLOCKS
const BACKGROUND_BLOCK = preload("res://Prefabs/Blocks/background_block_prefab.tscn")
const DEEP_BACKGROUND_BLOCK = preload("res://Prefabs/Blocks/deep_background_block_prefab.tscn")
const DEEPEST_BACKGROUND_BLOCK = preload("res://Prefabs/Blocks/deepest_background_block_prefab.tscn")
const STONE_BLOCK = preload("res://Prefabs/Blocks/stone_block.tscn")
const COPPER_ORE_BLOCK = preload("res://Prefabs/Blocks/copper_block_prefab.tscn")
const IRON_ORE_BLOCK = preload("res://Prefabs/Blocks/iron_ore_block_prefab.tscn")
const SILVER_ORE_BLOCK = preload("res://Prefabs/Blocks/silver_block_prefab.tscn")
const GOLD_ORE_BLOCK = preload("res://Prefabs/Blocks/gold_block_prefab.tscn")
const DIAMOND_BLOCK = preload("res://Prefabs/Blocks/diamond_block.tscn")
const BEDROCK_BLOCK = preload("res://Prefabs/Blocks/bedrock_block_prefab.tscn")

#DECORATIONS
const TORCH_BLOCK = preload("res://Prefabs/Blocks/torch_block_prefab.tscn")
#const ROCK_DECORATION = preload()
#const ROOF_ROCK_DECORATION = preload()

#Shop
const COUNT_OF_TORCHS: int = 12

#Grid
var grid = []

#Runs all the functions to generate the level
func _ready():
	randomize()
	initalize_grid()
	generate_cave()
	draw_cave()

#Creates the grid, assigning true and false to each point
func initalize_grid():
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT_OF_FALL_AREA):
			if(x < round(WIDTH/2 + 4) && x > round(WIDTH/2) - 4):
				grid[x].append(false)
			else:
				grid[x].append(randf() > 0.45)
		for y in range(HEIGHT_OF_CAVE - HEIGHT_OF_WIN_ROOM):
			var shop_block = false
			for i in AMOUNT_OF_SHOPS:
				if y > HEIGHT_OF_CAVE/(i+1) && y < HEIGHT_OF_CAVE/(i+1) + SHOP_HEIGHT:
					grid[x].append(false)
					shop_block = true
				else: if y > HEIGHT_OF_CAVE/(i+1) - SHOP_HEIGHT/2 && y < HEIGHT_OF_CAVE/(i+1) + SHOP_HEIGHT + SHOP_HEIGHT/2:
					grid[x].append(true)
					shop_block = true
			if shop_block == false:
				grid[x].append(randf() > 0.45)
			
		for y in range(HEIGHT_OF_WIN_ROOM):
			grid[x].append(true)

#Takes the random false points across the graph and enlargens them creating realistic erosion
func generate_cave():
	for i in range(CAVE_SMOOTHING):
		var new_grid = grid.duplicate(true)
		for x in range(WIDTH):
			for y in range(HEIGHT_OF_CAVE):
				var wall_count = count_neighboring_walls(x, y)
				for s in AMOUNT_OF_SHOPS:
					if y > HEIGHT_OF_CAVE/(s+1) - SHOP_HEIGHT/2 && y < HEIGHT_OF_CAVE/(s+1) + SHOP_HEIGHT + SHOP_HEIGHT/2:
						pass
					else: if grid[x][y]:
						new_grid[x][y] = wall_count > 3
					else:
						new_grid[x][y] = wall_count > 4
		grid = new_grid

#Counts the points that are true around a target point
func count_neighboring_walls(x, y):
	var count = 0
	for i in range(-1, 2):
		for j in range(-1, 2):
			if i == 0 and j == 0:
				continue
			var nx = x + i
			var ny = y + j
			if nx < 0 or nx >= WIDTH or ny < 0 or ny >= HEIGHT_OF_CAVE:
				count += 1
			elif grid[nx][ny]:
				count += 1
	return count

#using the graph we instaniate an object for each point and depending on the height we 
#instaniate an ore instead of a stone block
func draw_cave():
	for x in range(THICKNESS_OF_BORDERS):
		for y in range(HEIGHT_OF_CAVE + THICKNESS_OF_BORDERS + THICKNESS_OF_BORDERS):
			var cell = BEDROCK_BLOCK.instantiate()
			cell.position = Vector2(-x * CELL_SIZE, y * CELL_SIZE)
			add_child(cell) 
		
	for x in range(THICKNESS_OF_BORDERS):
		for y in range(HEIGHT_OF_CAVE + THICKNESS_OF_BORDERS):
			var cell = BEDROCK_BLOCK.instantiate()
			cell.position = Vector2((x + WIDTH) * CELL_SIZE, y * CELL_SIZE)
			add_child(cell) 
	
	for x in range(WIDTH):
		for y in range(THICKNESS_OF_BORDERS):
			var cell = BEDROCK_BLOCK.instantiate()
			cell.position = Vector2(x * CELL_SIZE, (y + HEIGHT_OF_CAVE) * CELL_SIZE)
			add_child(cell) 
		
	var amount_of_torchs = 0
	for x in range(WIDTH):
		for y in range(HEIGHT_OF_CAVE):
			var cell = null
			for i in AMOUNT_OF_SHOPS:
					if y - HEIGHT_OF_FALL_AREA >= HEIGHT_OF_CAVE/(i+1) && y - HEIGHT_OF_FALL_AREA <= HEIGHT_OF_CAVE/(i+1) + 3 && (x < WIDTH/2 - 6 || x > WIDTH/2 + 6):
						cell = BEDROCK_BLOCK.instantiate()
						cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
						add_child(cell)
					else:if y - HEIGHT_OF_FALL_AREA >= HEIGHT_OF_CAVE/(i+1) + SHOP_HEIGHT && y - HEIGHT_OF_FALL_AREA <= HEIGHT_OF_CAVE/(i+1) + SHOP_HEIGHT + 3  && (x < WIDTH/2 - 6 || x > WIDTH/2 + 6):
						cell = BEDROCK_BLOCK.instantiate()
						cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
						add_child(cell) 
					else:if y - HEIGHT_OF_FALL_AREA == HEIGHT_OF_CAVE/(i+1) + SHOP_HEIGHT - 1 && x == WIDTH/3:
						cell = BEDROCK_BLOCK.instantiate()#OIL REFILL
						#cell.connect("interacted_with", $"../../Player")
						cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
						add_child(cell) 
					else:
						cell = null
			if grid[x][y]:
				if cell == null:
					if(randf() * HEIGHT_OF_CAVE > (randf() * DIAMOND_RARITY + 1) * (HEIGHT_OF_CAVE - y)):
						cell = DIAMOND_BLOCK.instantiate()
						cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
						add_child(cell) 
					else:if(randf() * HEIGHT_OF_CAVE > (randf() * GOLD_ORE_RARITY + 1) * (HEIGHT_OF_CAVE - y)):
						cell = GOLD_ORE_BLOCK.instantiate()
						cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
						add_child(cell) 
					else:if(randf() * HEIGHT_OF_CAVE > (randf() * SILVER_ORE_RARITY + 1) * (HEIGHT_OF_CAVE - y)):
						cell = SILVER_ORE_BLOCK.instantiate()
						cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
						add_child(cell) 
					else:if(randf() * HEIGHT_OF_CAVE > (randf() * IRON_ORE_RARITY + 1) * (HEIGHT_OF_CAVE - y)):
						cell = IRON_ORE_BLOCK.instantiate()
						cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
						add_child(cell) 
					else:if(randf() * HEIGHT_OF_CAVE > (randf() * COPPER_ORE_RARITY + 1) * (HEIGHT_OF_CAVE - y)):
						cell = COPPER_ORE_BLOCK.instantiate()
						cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
						add_child(cell) 
					else:
						cell = STONE_BLOCK.instantiate()
						cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
						add_child(cell)
			else:
				if cell == null:
					var wall_count = count_neighboring_walls(x, y)
					if wall_count > 0:
						cell = BACKGROUND_BLOCK.instantiate()
					else:
						wall_count += count_neighboring_walls(x+1, y)
						wall_count += count_neighboring_walls(x-1, y)
						wall_count += count_neighboring_walls(x+1, y-1)
						wall_count += count_neighboring_walls(x-1, y+1)
						wall_count += count_neighboring_walls(x+1, y+1)
						wall_count += count_neighboring_walls(x-1, y-1)
						wall_count += count_neighboring_walls(x, y+1)
						wall_count += count_neighboring_walls(x, y-1)
						if wall_count > 0:
							cell = DEEP_BACKGROUND_BLOCK.instantiate()
						else:
							cell = DEEPEST_BACKGROUND_BLOCK.instantiate()
						
					cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
					add_child(cell) 
				
		if x == WIDTH/COUNT_OF_TORCHS * amount_of_torchs:
			amount_of_torchs += 1
			for i in AMOUNT_OF_SHOPS:
				var torch = TORCH_BLOCK.instantiate()
				torch.position = Vector2(x * CELL_SIZE, (((HEIGHT_OF_CAVE)/(i+1) + SHOP_HEIGHT/2) + HEIGHT_OF_FALL_AREA) * CELL_SIZE)
				add_child(torch) 
