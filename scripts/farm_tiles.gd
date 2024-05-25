extends Node

var FarmTile = preload("res://scenes/farm_tile.tscn")

var TILE_SIZE = Vector2(56, 56);
var tiles = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create the farm tiles
	var TOP_LEFT = Vector2(TILE_SIZE.x * 7, TILE_SIZE.y * 2)
	for i in Constants.FARM_DIMENSIONS.x:
		tiles.append([])
		for j in Constants.FARM_DIMENSIONS.y:
			var tile = FarmTile.instantiate()
			tile.position = TOP_LEFT + TILE_SIZE * Vector2(i, j)
			tile.scale *= TILE_SIZE / Vector2(16, 16)
			tile.grid_location = Vector2(i, j)
			tiles[i].append(tile)
			self.add_child(tile)

func use_card(card, grid_position):
	var shape = Helper.get_tile_shape(card.size)
	for tile in shape:
		var target = grid_position + tile
		if not Helper.in_bounds(target):
			continue
		if card.type == "Seed":
			tiles[target.x][target.y].plant_seed(card)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
