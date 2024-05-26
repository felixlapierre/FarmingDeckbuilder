extends Node

var FarmTile = preload("res://scenes/farm_tile.tscn")

var TILE_SIZE = Vector2(56, 56);
var TOP_LEFT
var tiles = []

signal card_played

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create the farm tiles
	TOP_LEFT = Vector2(TILE_SIZE.x * 7, TILE_SIZE.y * 2)
	for i in Constants.FARM_DIMENSIONS.x:
		tiles.append([])
		for j in Constants.FARM_DIMENSIONS.y:
			var tile = FarmTile.instantiate()
			tile.position = TOP_LEFT + TILE_SIZE * Vector2(i, j)
			tile.scale *= TILE_SIZE / Vector2(16, 16)
			tile.grid_location = Vector2(i, j)
			tiles[i].append(tile)
			$Tiles.add_child(tile)

func use_card(card, grid_position):
	var shape = Helper.get_tile_shape(card.size)
	for tile in shape:
		var target = grid_position + tile
		if not Helper.in_bounds(target):
			continue
		if card.type == "Seed":
			tiles[target.x][target.y].plant_seed(card)
	clear_overlay()
	card_played.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_tile_hover(grid_position: Vector2):
	if Global.selected_card.type == "NONE":
		return
	clear_overlay()
	var shape = Helper.get_tile_shape(Global.selected_card.size)
	
	for item in shape:
		if not Helper.in_bounds(item + grid_position):
			continue
		var sprite = Sprite2D.new()
		sprite.texture = load("res://assets/custom/SelectTile.png")
		sprite.position = TOP_LEFT + (item + grid_position) * TILE_SIZE + TILE_SIZE / 2
		sprite.scale *= TILE_SIZE / sprite.texture.get_size()
		sprite.z_index = 1
		$SelectOverlay.add_child(sprite)

func clear_overlay():
	for node in $SelectOverlay.get_children():
		$SelectOverlay.remove_child(node)
		node.queue_free()

func process_one_week():
	for tile in $Tiles.get_children():
		tile.grow_one_week()
