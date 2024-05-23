extends Node

var FarmTile = preload("res://scenes/farm_tile.tscn")

var TILE_SIZE = Vector2(56, 56);
var FARM_DIMENSIONS = Vector2(6, 6);
var tiles = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create the farm tiles
	var TOP_LEFT = Vector2(TILE_SIZE.x * 3, TILE_SIZE.y * 2) + TILE_SIZE / 2
	for i in FARM_DIMENSIONS.x:
		for j in FARM_DIMENSIONS.y:
			var tile = FarmTile.instantiate()
			tile.position = TOP_LEFT + TILE_SIZE * Vector2(i, j)
			tile.scale *= TILE_SIZE / Vector2(16, 16)
			self.add_child(tile)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
