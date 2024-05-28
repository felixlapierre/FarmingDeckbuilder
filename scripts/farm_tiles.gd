extends Node

var FarmTile = preload("res://scenes/farm_tile.tscn")

var TILE_SIZE = Vector2(56, 56);
var TOP_LEFT
var tiles = []
var active_effects = []

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
	var shape = get_targeted_tiles(grid_position, Global.selected_card.size)
	for target in shape:
		if not Helper.in_bounds(target):
			continue
		var target_tile = tiles[target.x][target.y]
		if not is_eligible_card(card, target_tile):
			continue
		if card.type == "SEED":
			target_tile.plant_seed_animate(card)
		elif card.type == "ACTION":
			use_action_card(card, target_tile)
		elif card.type == "STRUCTURE":
			target_tile.build_structure(card)
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
	var shape = get_targeted_tiles(grid_position, Global.selected_card.size)

	for item in shape:
		var error = false
		if not Helper.in_bounds(item):
			error = true
		else:
			var targeted_tile = tiles[item.x][item.y]
			error = !is_eligible_card(card, targeted_tile)
		var sprite = Sprite2D.new()
		sprite.texture = load("res://assets/custom/SelectTile.png")
		sprite.position = TOP_LEFT + (item) * TILE_SIZE + TILE_SIZE / 2
		sprite.scale *= TILE_SIZE / sprite.texture.get_size()
		sprite.z_index = 1
		if error:
			sprite.modulate = Color(191.0/256.0, 44.0/256.0, 44.0/256.0)
		else:
			sprite.modulate = Color(98.0/256.0, 240.0/256.0, 70.0/256.0)
		$SelectOverlay.add_child(sprite)

func is_eligible_card(card, targeted_tile):
	match card.type:
		"SEED", "STRUCTURE":
			return targeted_tile.state == Constants.TileState.Empty
		"ACTION":
			return card.targets.has(Constants.TileState.keys()[targeted_tile.state])
		_:
			return true

func get_targeted_tiles(grid_position, size):
	var shape = []
	if Global.selected_card.size != -1:
		for item in Helper.get_tile_shape(Global.selected_card.size):
			shape.append(item + grid_position)
	else:
		for i in range(0, Constants.FARM_DIMENSIONS.x):
			for j in range(0, Constants.FARM_DIMENSIONS.y):
				shape.append(Vector2(i, j))
	return shape

func pct(num):
	return float(num)/100.0

func clear_overlay():
	for node in $SelectOverlay.get_children():
		$SelectOverlay.remove_child(node)
		node.queue_free()

func process_one_week():
	var growing_tiles = []
	for tile in $Tiles.get_children():
		if tile.state == Constants.TileState.Growing:
			growing_tiles.append(tile)
	growing_tiles.shuffle()
	for tile in growing_tiles:
		tile.grow_one_week()
		await get_tree().create_timer(0.01).timeout
	for tile in $Tiles.get_children():
		tile.lose_irrigate()
	var expired_effects = []
	for effect in active_effects:
		perform_action(effect.action, effect.tile)
		effect.duration_remaining -= 1
		if effect.duration_remaining <= 0:
			expired_effects.append(effect)
	for effect in expired_effects:
		active_effects.erase(effect)

func use_action_card(card, tile):
	for action in card.actions:
		perform_action(action, tile)
		if action.has("duration") and action.duration > 0:
			active_effects.append({
				"action": action,
				"tile": tile,
				"duration_remaining": action.duration - 1
			})

func perform_action(action, tile):
	match action.name:
		"harvest":
			tile.harvest()
		"irrigate":
			tile.irrigate()
		"grow":
			tile.grow_one_week()

func gain_yield(yield_amount):
	on_yield_gained.emit(yield_amount)
