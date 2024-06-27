extends Node
class_name Farm

var FarmTile = preload("res://src/farm/tile.tscn")

var event_manager: EventManager

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
	var x = Constants.VIEWPORT_SIZE.x/2 - TILE_SIZE.x * Constants.FARM_DIMENSIONS.x / 2
	TOP_LEFT = Vector2(x, TILE_SIZE.y * 0.5)
	for i in Constants.FARM_DIMENSIONS.x:
		tiles.append([])
		for j in Constants.FARM_DIMENSIONS.y:
			var tile = FarmTile.instantiate()
			tile.position = TOP_LEFT + TILE_SIZE * Vector2(i, j)
			tile.scale *= TILE_SIZE / Vector2(16, 16)
			tile.grid_location = Vector2(i, j)
			tiles[i].append(tile)
			tile.tile_hovered.connect(on_tile_hover)
			tile.on_event.connect(on_farm_tile_on_event)
			if i >= Constants.PURPLE_GTE_INDEX:
				tile.purple = true
			$Tiles.add_child(tile)

func setup(p_event_manager: EventManager):
	event_manager = p_event_manager
	for tile in $Tiles.get_children():
		tile.event_manager = event_manager

func use_card(grid_position):
	var card = Global.selected_card
	if Global.selected_structure != null:
		tiles[grid_position.x][grid_position.y]\
				.build_structure(Global.selected_structure, Global.rotate)
		clear_overlay()
		card_played.emit(Global.selected_structure)
		return
	if card == null or card.cost > $"../TurnManager".energy:
		return
	var size = Global.selected_card.size
	var targets = get_targeted_tiles(grid_position, size, Global.shape, Global.rotate)
	use_card_on_targets(card, targets, false)
	clear_overlay()
	process_effect_queue()
	card_played.emit(card)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_shape != Global.shape and hovered_tile != null:
		show_select_overlay()
	if hovered_tile == null or (Global.selected_card == null and Global.selected_structure == null) and $SelectOverlay.get_children().size() > 0:
		clear_overlay()
	
func show_select_overlay():
	var size = 0
	var targets = []
	if Global.selected_card != null:
		var crd = Global.selected_card
		size = crd.size
		targets = crd.targets if crd.type == "ACTION" else ["Empty"]
	elif Global.selected_structure != null:
		size = Global.selected_structure.size
		targets = ["Empty", "Growing", "Mature"]
	if hovered_tile == null or size == 0:
		return
	clear_overlay()
	var grid_position = hovered_tile.grid_location
	var shape = Global.shape
	if Global.selected_structure != null:
		shape = Enums.CursorShape.Elbow
		var sprite = Sprite2D.new()
		sprite.texture = Global.selected_structure.texture
		sprite.position = TOP_LEFT + (grid_position) * TILE_SIZE + TILE_SIZE / 2
		sprite.scale *= TILE_SIZE / sprite.texture.get_size()
		sprite.z_index = 1
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		$SelectOverlay.add_child(sprite)
		
	var targeted_grid_locations = get_targeted_tiles(grid_position, size, shape, Global.rotate)
	var yld_preview_yellow = 0
	var yld_preview_purple = 0

	for item in targeted_grid_locations:
		var error = false
		if not Helper.in_bounds(item):
			error = true
		else:
			var targeted_tile = tiles[item.x][item.y]
			error = !is_eligible(targets, targeted_tile)
			if Global.selected_card != null:
				var preview = preview_yield(Global.selected_card, targeted_tile)
				yld_preview_purple += preview.purple
				yld_preview_yellow += preview.yellow
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

func is_eligible(targets, targeted_tile):
	return targets.has(Enums.TileState.keys()[targeted_tile.state])

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
		var n_effect = effect.copy().set_location(grid_location)
		if n_effect.name == "spread":
			n_effect.card = tiles[grid_location.x][grid_location.y].seed
		effect_queue.append(n_effect)

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
		"increase_yield":
			tile.multiply_yield(1.0 + effect.strength)
		"add_yield":
			tile.add_yield(effect.strength)
		"plant":
			var card = effect.card.copy()
			if effect.strength > 0:
				card.yld += effect.strength
			effect_queue.append_array(tile.plant_seed(card))
		"spread":
			if randf_range(0, 1) <= effect.strength:
				spread(effect.card, tile.grid_location, 8, Enums.CursorShape.Elbow)
		"energy":
			on_energy_gained.emit(effect.strength)
		"draw":
			on_card_draw.emit(effect.strength, null)
		"absorb":
			tile.increase_permanent_mult(tile.IRRIGATED_MULTIPLIER * effect.strength)
		"destroy_tile":
			tile.destroy()

func gain_yield(yield_amount, purple):
	on_yield_gained.emit(int(yield_amount), purple)

func do_winter_clear():
	for tile in $Tiles.get_children():
		tile.do_winter_clear()
		tile.set_blight_targeted(false)
		tile.lose_irrigate()

func spread(card, grid_position, size, shape):
	var targets = get_targeted_tiles(grid_position, size, shape, 0)
	targets.shuffle()
	use_card_on_targets(card, targets, true)

func use_card_on_targets(card, targets, only_first):
	for target in targets:
		if not Helper.in_bounds(target):
			continue
		var target_tile = tiles[target.x][target.y]
		if not is_eligible(card.targets if card.type == "ACTION" else ["Empty"], \
			target_tile):
			continue
		if card.type == "SEED":
			effect_queue.append_array(target_tile.plant_seed_animate(card))
		elif card.type == "ACTION":
			use_action_card(card, Vector2(target.x, target.y))
		if only_first:
			return

func gain_energy(amount):
	on_energy_gained.emit(amount)

func preview_yield(card, targeted_tile):
	var yld_purple = 0
	var yld_yellow = 0
	if card.get_effect("harvest") != null:
		var yld = targeted_tile.preview_harvest()
		if targeted_tile.purple:
			yld_purple += yld
		else:
			yld_yellow += yld
	var increase_yield = card.get_effect("increase_yield")
	if increase_yield != null:
		yld_purple *= 1.0 + increase_yield.strength
		yld_yellow *= 1.0 + increase_yield.strength
	return {
		"purple": yld_purple,
		"yellow": yld_yellow
	}

func on_expand_farm():
	for tile in $Tiles.get_children():
		tile.do_active_check()

func destroy_blighted_tiles():
	for tile in $Tiles.get_children():
		if tile.blight_targeted == true:
			tile.set_blighted()

func use_card_random_tile(card: CardData, times: int):
	var tiles = []
	for tile in $Tiles.get_children():
		if tile.state != Enums.TileState.Inactive:
			tiles.append(tile)
	tiles.shuffle()
	var locations = []
	for i in range(times):
		locations.append(tiles[i].grid_location)
	use_card_on_targets(card, locations, false)
	
func get_all_tiles() -> Array[Tile]:
	var result: Array[Tile] = []
	result.assign($Tiles.get_children())
	return result

func on_farm_tile_on_event(event_type: EventManager.EventType, specific_args):
	event_manager.notify_specific_args(event_type, specific_args)
