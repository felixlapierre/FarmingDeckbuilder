extends Node

var FarmTile = preload("res://scenes/farm_tile.tscn")

var TILE_SIZE = Vector2(56, 56);
var TOP_LEFT
var tiles = []
var active_actions = []
var effect_queue = []
var hovered_tile = null
var current_shape

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
			tile.tile_hovered.connect(on_tile_hover)
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
			use_action_card(card, Vector2(target.x, target.y))
		elif card.type == "STRUCTURE":
			target_tile.build_structure(card)
	clear_overlay()
	card_played.emit(card)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_shape != Global.shape and hovered_tile != null:
		show_select_overlay()
	if hovered_tile == null and $SelectOverlay.get_children().size() > 0:
		clear_overlay()
	
func show_select_overlay():
	var card = Global.selected_card
	if card.type == "NONE" or hovered_tile == null:
		return
	clear_overlay()
	var grid_position = hovered_tile.grid_location
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
			sprite.modulate = Color8(190, 44, 44)
		else:
			sprite.modulate = Color8(98, 240, 70)
		$SelectOverlay.add_child(sprite)

func is_eligible_card(card, targeted_tile):
	match card.type:
		"SEED":
			return targeted_tile.state == Constants.TileState.Empty
		"ACTION":
			return card.targets.has(Constants.TileState.keys()[targeted_tile.state])
		"STRUCTURE":
			return ["Empty", "Growing", "Mature"].has(Constants.TileState.keys()[targeted_tile.state])
		_:
			return true

func get_targeted_tiles(grid_position, size):
	var shape = []
	if Global.selected_card.size != -1:
		for item in Helper.get_tile_shape_rotated(Global.selected_card.size, Global.shape, Global.rotate):
			shape.append(item + grid_position)
			print(item + grid_position)
	else:
		for i in range(0, Constants.FARM_DIMENSIONS.x):
			for j in range(0, Constants.FARM_DIMENSIONS.y):
				shape.append(Vector2(i, j))
	return shape

func pct(num):
	return float(num)/100.0

func on_tile_hover(tile):
	hovered_tile = tile
	if tile != null:
		show_select_overlay()

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
	for action in active_actions:
		effect_queue.append({
			"effect": action.effect,
			"grid_location": action.grid_location
		})
		action.duration_remaining -= 1
		if action.duration_remaining <= 0:
			expired_effects.append(action)
	for effect in expired_effects:
		active_actions.erase(effect)
	process_effect_queue()
	for tile in $Tiles.get_children():
		effect_queue.append_array(tile.start_of_week_effects())
	process_effect_queue()

func use_action_card(card, grid_location):
	for effect in card.effects:
		effect_queue.append({
			"effect": effect,
			"grid_location": grid_location
		})
		if effect.has("duration") and effect.duration > 0:
			active_actions.append({
				"effect": effect,
				"grid_location": grid_location,
				"duration_remaining": effect.duration - 1
			})
	process_effect_queue()

func process_effect_queue():
	while effect_queue.size() > 0:
		var next = effect_queue.pop_front()
		var tile = tiles[next.grid_location.x][next.grid_location.y]
		perform_effect(next.effect, tile)

func perform_effect(effect, tile):
	match effect.name:
		"harvest":
			tile.harvest()
		"irrigate":
			tile.irrigate()
		"grow":
			tile.grow_one_week()

func gain_yield(yield_amount):
	on_yield_gained.emit(yield_amount)
