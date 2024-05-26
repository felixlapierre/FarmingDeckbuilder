extends Node

var FarmTile = preload("res://scenes/farm_tile.tscn")

var TILE_SIZE = Vector2(56, 56);
var TOP_LEFT
var tiles = []

signal card_played
signal on_yield_gained

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
	if card == Global.NO_CARD or card.cost > $"../".energy:
		return
	var shape = Helper.get_tile_shape(card.size)
	for tile in shape:
		var target = grid_position + tile
		if not Helper.in_bounds(target):
			continue
		if card.type == "SEED":
			tiles[target.x][target.y].plant_seed_animate(card)
		elif card.type == "ACTION":
			perform_action(card, tiles[target.x][target.y])
	clear_overlay()
	card_played.emit(card)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_tile_hover(grid_position: Vector2):
	var card = Global.selected_card
	if card.type == "NONE":
		return
	clear_overlay()
	var shape = Helper.get_tile_shape(Global.selected_card.size)
	for item in shape:
		var target_grid_position = item + grid_position
		var error = false
		if not Helper.in_bounds(target_grid_position):
			error = true
		else:
			var targeted_tile = tiles[target_grid_position.x][target_grid_position.y]
			if card.type == "SEED" and targeted_tile.state != Constants.TileState.Empty:
				error = true
			elif card.type == "ACTION" and !card.targets.has(Constants.TileState.keys()[targeted_tile.state]):
				error = true
		var sprite = Sprite2D.new()
		sprite.texture = load("res://assets/custom/SelectTile.png")
		sprite.position = TOP_LEFT + (target_grid_position) * TILE_SIZE + TILE_SIZE / 2
		sprite.scale *= TILE_SIZE / sprite.texture.get_size()
		sprite.z_index = 1
		if error:
			sprite.modulate = Color(191.0/256.0, 44.0/256.0, 44.0/256.0)
		else:
			sprite.modulate = Color(98.0/256.0, 240.0/256.0, 70.0/256.0)
		$SelectOverlay.add_child(sprite)

func pct(num):
	return float(num)/100.0

func clear_overlay():
	for node in $SelectOverlay.get_children():
		$SelectOverlay.remove_child(node)
		node.queue_free()

func process_one_week():
	var all_tiles = []
	for tile in $Tiles.get_children():
		if tile.state == Constants.TileState.Growing:
			all_tiles.append(tile)
	all_tiles.shuffle()
	for tile in all_tiles:
		tile.grow_one_week()
		await get_tree().create_timer(0.01).timeout

func perform_action(card, tile):
	for action in card.actions:
		match action.name:
			"harvest":
				tile.harvest()

func gain_yield(yield_amount):
	on_yield_gained.emit(yield_amount)
