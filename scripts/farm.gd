extends Node

var FarmTile = preload("res://scenes/tile.tscn")

var TILE_SIZE = Vector2(91, 91);
var TOP_LEFT
var tiles = []
var active_actions = []
var effect_queue = []
var next_turn_effects = []
var hovered_tile = null
var current_shape

signal card_played
signal on_yield_gained
signal on_preview_yield
signal on_energy_gained
signal on_card_draw

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
			if i >= 3:
				tile.purple = true
			$Tiles.add_child(tile)

func use_card(card, grid_position):
	if card == null or (card.cost > $"../".energy and card.type != "STRUCTURE"):
		return
	var size = Global.selected_card.size
	if card.type == "STRUCTURE":
		size = 1
	var targets = get_targeted_tiles(grid_position, size, Global.shape, Global.rotate)
	use_card_on_targets(card, targets, false)
	clear_overlay()
	process_effect_queue()
	card_played.emit(card)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_shape != Global.shape and hovered_tile != null:
		show_select_overlay()
	if (hovered_tile == null or Global.selected_card == null) and $SelectOverlay.get_children().size() > 0:
		clear_overlay()
	
func show_select_overlay():
	var card = Global.selected_card
	if card == null or hovered_tile == null or card.size == 0:
		return
	clear_overlay()
	var grid_position = hovered_tile.grid_location
	var shape = Global.shape
	if card.type == "STRUCTURE":
		shape = Enums.CursorShape.Elbow
		var sprite = Sprite2D.new()
		sprite.texture = card.texture
		sprite.position = TOP_LEFT + (grid_position) * TILE_SIZE + TILE_SIZE / 2
		sprite.scale *= TILE_SIZE / sprite.texture.get_size()
		sprite.z_index = 1
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		$SelectOverlay.add_child(sprite)
		
	var targets = get_targeted_tiles(grid_position, card.size, shape, Global.rotate)
	var yld_preview_yellow = 0
	var yld_preview_purple = 0

	for item in targets:
		var error = false
		if not Helper.in_bounds(item):
			error = true
		else:
			var targeted_tile = tiles[item.x][item.y]
			error = !is_eligible_card(card, targeted_tile)
			var yld_purple = 0
			var yld_yellow = 0
			if card.get_effect("harvest") != null:
				var yld = targeted_tile.preview_harvest()
				if targeted_tile.purple:
					yld_purple += yld
				else:
					yld_yellow += yld
			var multiply_yield = card.get_effect("multiply_yield")
			if multiply_yield != null:
				yld_purple *= multiply_yield.strength
				yld_yellow *= multiply_yield.strength
			yld_preview_purple += yld_purple
			yld_preview_yellow += yld_yellow
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
	if yld_preview_purple + yld_preview_yellow > 0:
		on_preview_yield.emit(yld_preview_yellow, yld_preview_purple)

func is_eligible_card(card, targeted_tile):
	match card.type:
		"SEED":
			return targeted_tile.state == Enums.TileState.Empty
		"ACTION":
			return card.targets.has(Enums.TileState.keys()[targeted_tile.state])
		"STRUCTURE":
			return ["Empty", "Growing", "Mature"].has(Enums.TileState.keys()[targeted_tile.state])
		_:
			return true

func get_targeted_tiles(grid_position, size, shape, rotate):
	var tiles = []
	if size != -1:
		for item in Helper.get_tile_shape_rotated(size, shape, rotate):
			tiles.append(item + grid_position)
	else:
		for i in range(0, Constants.FARM_DIMENSIONS.x):
			for j in range(0, Constants.FARM_DIMENSIONS.y):
				tiles.append(Vector2(i, j))
	return tiles

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
	on_preview_yield.emit(0, 0) #This signals to clear the preview

func process_one_week():
	for tile in $Tiles.get_children():
		effect_queue.append_array(tile.get_before_grow_effects())
	process_effect_queue()

	var growing_tiles = []
	for tile in $Tiles.get_children():
		if tile.state == Enums.TileState.Growing:
			growing_tiles.append(tile)
	growing_tiles.shuffle()
	for tile in growing_tiles:
		effect_queue.append_array(tile.grow_one_week())
		await get_tree().create_timer(0.01).timeout
	process_effect_queue()
	for tile in $Tiles.get_children():
		effect_queue.append_array(tile.get_after_grow_effects())
	process_effect_queue()
	for tile in $Tiles.get_children():
		tile.lose_irrigate()
	for tile in $Tiles.get_children():
		effect_queue.append_array(tile.get_turn_start_effects())
	process_effect_queue()
	effect_queue.append_array(next_turn_effects)
	next_turn_effects.clear()
	process_effect_queue()

func use_action_card(card, grid_location):
	for effect in card.effects:
		effect_queue.append(effect.copy().set_location(grid_location))

func process_effect_queue():
	while effect_queue.size() > 0:
		var next = effect_queue.pop_front()
		var tile = tiles[next.grid_location.x][next.grid_location.y]
		perform_effect(next, tile)

func perform_effect(effect, tile: Tile):
	match effect.name:
		"harvest":
			effect_queue.append_array(tile.harvest())
		"irrigate":
			tile.irrigate()
			if effect.strength > 1:
				effect.strength -= 1
				next_turn_effects.append(effect)
		"grow":
			for i in range(effect.strength):
				effect_queue.append_array(tile.grow_one_week())
		"multiply_yield":
			tile.multiply_yield(effect.strength)
		"add_yield":
			tile.add_yield(effect.strength)
		"plant":
			effect_queue.append_array(tile.plant_seed(effect.card))
			if effect.strength > 0:
				effect_queue.append(Effect.new("grow", effect.strength, "", "self", tile.grid_location, null))
		"spread":
			spread(effect.card, tile.grid_location, 8, Enums.CursorShape.Elbow)
		"energy":
			on_energy_gained.emit(effect.strength)
		"draw":
			on_card_draw.emit(effect.strength, null)
		"absorb":
			tile.increase_permanent_mult(tile.IRRIGATED_MULTIPLIER * effect.strength)

func gain_yield(yield_amount, purple):
	on_yield_gained.emit(int(yield_amount), purple)

func do_winter_clear():
	for tile in $Tiles.get_children():
		tile.do_winter_clear()

func spread(card, grid_position, size, shape):
	var targets = get_targeted_tiles(grid_position, size, shape, 0)
	targets.shuffle()
	use_card_on_targets(card, targets, true)

func use_card_on_targets(card, targets, only_first):
	for target in targets:
		if not Helper.in_bounds(target):
			continue
		var target_tile = tiles[target.x][target.y]
		if not is_eligible_card(card, target_tile):
			continue
		if card.type == "SEED":
			effect_queue.append_array(target_tile.plant_seed_animate(card))
		elif card.type == "ACTION":
			use_action_card(card, Vector2(target.x, target.y))
		elif card.type == "STRUCTURE":
			target_tile.build_structure(card, Global.rotate)
		if only_first:
			return

func gain_energy(amount):
	on_energy_gained.emit(amount)
