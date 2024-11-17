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
var selection = []

signal card_played
signal after_card_played
signal on_yield_gained
signal on_preview_yield
signal on_energy_gained
signal on_card_draw
signal on_show_tile_preview
signal on_hide_tile_preview
signal try_move_structure
signal no_energy

var hover_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func setup(p_event_manager: EventManager):
	# Create the farm tiles
	var x = Constants.VIEWPORT_SIZE.x/2 - TILE_SIZE.x * Constants.FARM_DIMENSIONS.x / 2
	TOP_LEFT = Vector2(x, TILE_SIZE.y * 0.5)
	for i in Constants.FARM_DIMENSIONS.x:
		tiles.append([])
		for j in Constants.FARM_DIMENSIONS.y:
			var tile = FarmTile.instantiate()
			tile.position = TOP_LEFT + TILE_SIZE * Vector2(i, j)
			tile.set_tile_size(TILE_SIZE)
			tile.grid_location = Vector2(i, j)
			tiles[i].append(tile)
			tile.tile_hovered.connect(on_tile_hover)
			tile.on_event.connect(on_farm_tile_on_event)
			tile.on_yield_gained.connect(gain_yield)
			if i >= Constants.PURPLE_GTE_INDEX:
				tile.purple = true
			$Tiles.add_child(tile)
	event_manager = p_event_manager
	for tile in $Tiles.get_children():
		tile.event_manager = event_manager
	

func use_card(grid_position):
	hover_time = 0.0
	var energy = $"../TurnManager".energy
	if Global.selected_card == null and Global.selected_structure == null:
		try_move_structure.emit(tiles[grid_position.x][grid_position.y])
		return
	if Global.selected_structure != null:
		var tile: Tile = tiles[grid_position.x][grid_position.y]
		if tile.state == Enums.TileState.Empty and tile.not_destroyed():
			tile.build_structure(Global.selected_structure, Global.rotate)
			clear_overlay()
			card_played.emit(Global.selected_structure)
		return
	if Global.selected_card == null or Global.selected_card.cost > energy:
		no_energy.emit()
		return
	var card = Global.selected_card.copy()
	# Handle X cost cards
	if card.cost == -1:
		for effect in card.effects:
			if effect.strength < 0:
				effect.strength = (effect.strength * -1) * energy
				card.cost = 1
	var targets = []
	if selection.size() > 0:
		targets.assign(selection)
	else:
		targets = get_targeted_tiles(grid_position, Global.selected_card, Global.selected_card.size, Global.shape, Global.rotate)
	card.register_events(event_manager, null)
	var args = EventArgs.SpecificArgs.new(tiles[grid_position.x][grid_position.y])
	args.play_args = EventArgs.PlayArgs.new(card)
	event_manager.notify_specific_args(EventManager.EventType.BeforeCardPlayed, args)
	# Animate
	var spriteframes: SpriteFrames = null
	var delay = 0.0
	var on = Enums.AnimOn.Mouse
	if card.animation != null:
		spriteframes = card.animation
		delay = card.delay
		on = card.anim_on
	elif card.get_effect("harvest") != null:
		spriteframes = load("res://src/animation/scythe_frames.tres")
		delay = 0.2
	if spriteframes != null:
		if on == Enums.AnimOn.Mouse:
			var location = grid_position if card.size == 9 else targets[0]
			do_animation(spriteframes, location)
		elif on == Enums.AnimOn.Tiles:
			for target in targets:
				var inbounds = Helper.in_bounds(target)
				var cantarget = tiles[target.x][target.y].card_can_target(card)
				if inbounds and cantarget:
					print(str(target.x) + ", " + str(target.y))
					do_animation(spriteframes, target)
		elif on == Enums.AnimOn.Mouse:
			do_animation(spriteframes, null)
	card_played.emit(Global.selected_card)
	await get_tree().create_timer(delay).timeout
	use_card_on_targets(card, targets, false)
	clear_overlay()
	process_effect_queue()
	event_manager.notify_specific_args(EventManager.EventType.AfterCardPlayed, args)
	card.unregister_events(event_manager)
	after_card_played.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !Settings.CLICK_MODE:
		hover_time += delta
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
	elif hovered_tile != null and (hover_time > Constants.HOVER_PREVIEW_DELAY or Settings.CLICK_MODE):
		clear_overlay()
		on_show_tile_preview.emit(hovered_tile)
		return
	if hovered_tile == null:
		return
	clear_overlay()
	if size == 0 and Global.selected_structure == null:
		$ConfirmButton.visible = Settings.CLICK_MODE
		return
	var grid_position = hovered_tile.grid_location
	var shape = Global.shape
	$ConfirmButton.visible = Settings.CLICK_MODE
	if Global.selected_structure != null:
		shape = Enums.CursorShape.Elbow
		var sprite = Sprite2D.new()
		sprite.texture = Global.selected_structure.texture
		sprite.position = TOP_LEFT + (grid_position) * TILE_SIZE + TILE_SIZE / 2
		sprite.scale *= TILE_SIZE / sprite.texture.get_size()
		sprite.z_index = 1
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		$SelectOverlay.add_child(sprite)
	
	var selected = Global.selected_card if Global.selected_card != null else Global.selected_structure
	var targeted_grid_locations = get_targeted_tiles(grid_position, selected, selected.size, shape, Global.rotate)
	var yld_preview_yellow = 0
	var yld_preview_purple = 0
	var yld_preview_green = 0
	var yld_preview_defer = false

	for item in targeted_grid_locations:
		var error = false
		if not Helper.in_bounds(item):
			error = true
		else:
			var targeted_tile = tiles[item.x][item.y]
			if Global.selected_card != null:
				error = !targeted_tile.card_can_target(Global.selected_card)
				if !error:
					var preview: EventArgs.HarvestArgs = Global.selected_card.preview_yield(targeted_tile)
					var specific = EventArgs.SpecificArgs.new(targeted_tile)
					specific.harvest_args = preview
					event_manager.notify_specific_args(EventManager.EventType.OnYieldPreview, specific)
					yld_preview_purple += preview.yld if preview.purple else 0.0
					yld_preview_yellow += preview.yld if !preview.purple else 0.0
					yld_preview_green += preview.green
					yld_preview_defer = yld_preview_defer or preview.delay
			elif Global.selected_structure != null:
				error = !targeted_tile.structure_can_target()
		var sprite = Sprite2D.new()
		sprite.texture = load("res://assets/custom/SelectTile.png")
		sprite.position = TOP_LEFT + (item) * TILE_SIZE + TILE_SIZE / 2
		sprite.scale *= TILE_SIZE / sprite.texture.get_size()
		sprite.z_index = 1
		if error:
			sprite.modulate = Color8(255, 0, 0)
		else:
			sprite.modulate = Color8(0, 255, 0)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		$SelectOverlay.add_child(sprite)
		selection.append(item)
	if yld_preview_purple != 0 or yld_preview_yellow != 0 or yld_preview_green != 0:
		on_preview_yield.emit({
			"yellow": yld_preview_yellow, 
			"purple": yld_preview_purple,
			"green": yld_preview_green,
			"defer": yld_preview_defer
		})

func get_targeted_tiles(grid_position, card, size, shape, rotate):
	var target_tiles = []
	if size != -1:
		if shape == Enums.CursorShape.Smart:
			for item in Helper.get_smart_select_shape(grid_position, tiles, card, $Tiles.get_global_mouse_position()):
				target_tiles.append(item)
		else:
			for item in Helper.get_tile_shape_rotated(size, shape, rotate):
				if Global.flip == 1:
					item.x = -item.x
				target_tiles.append(item + grid_position)
	else:
		for i in range(0, Constants.FARM_DIMENSIONS.x):
			for j in range(0, Constants.FARM_DIMENSIONS.y):
				target_tiles.append(Vector2(i, j))
	return target_tiles

func pct(num):
	return float(num)/100.0

func on_tile_hover(tile):
	if Settings.CLICK_MODE:
		await get_tree().create_timer(0.1).timeout
		hovered_tile = tile
		show_select_overlay()
	else:
		hover_time = 0.0
		hovered_tile = tile
		if tile != null:
			show_select_overlay()

func clear_overlay():
	for node in $SelectOverlay.get_children():
		$SelectOverlay.remove_child(node)
		node.queue_free()
	selection.clear()
	on_preview_yield.emit({
		"purple": 0,
		"yellow": 0,
		"green": 0,
		"defer": false
	}) #This signals to clear the preview
	on_hide_tile_preview.emit()
	$ConfirmButton.visible = false

func process_one_week(week: int):
	for tile in $Tiles.get_children():
		effect_queue.append_array(tile.get_before_grow_effects())
	process_effect_queue()

	if week < Global.WINTER_WEEK:
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
	var args = EventArgs.SpecificArgs.new(tiles[grid_location.x][grid_location.y])
	args.play_args = EventArgs.PlayArgs.new(card)
	event_manager.notify_specific_args(EventManager.EventType.OnActionCardUsed, args)
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
			effect_queue.append_array(tile.harvest(false))
		"harvest_delay":
			effect_queue.append_array(tile.harvest(true))
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
			var i = effect.strength
			while i >= 1.0:
				spread(effect.card, tile.grid_location, 8, Enums.CursorShape.Elbow)
				i -= 1.0
			if i > 0.0 and randf_range(0, 1) <= effect.strength:
				spread(effect.card, tile.grid_location, 8, Enums.CursorShape.Elbow)
		"energy":
			on_energy_gained.emit(effect.strength)
		"draw":
			if effect.on != "play":
				on_card_draw.emit(effect.strength, null)
		"destroy_tile":
			tile.destroy()
		"destroy_plant":
			tile.destroy_plant()
		"replant":
			effect_queue.append(Effect.new("plant", 0, "", "self", tile.grid_location, tile.seed.copy()))
		"add_recurring":
			if tile.seed.get_effect("plant") == null:
				var new_seed = tile.seed.copy()
				new_seed.effects.append(Effect.new("plant", 0, "harvest", "self", Vector2.ZERO, null))
				tile.seed = new_seed
				tile.play_effect_particles()
		"draw_target":
			var new_seed = tile.seed.copy()
			new_seed.effects.append(load("res://src/effect/data/fleeting.tres"))
			on_card_draw.emit(effect.strength, new_seed.copy())
		"add_blight_yield":
			tile.seed_base_yield += effect.strength * event_manager.turn_manager.blight_damage

func gain_yield(tile: Tile, args: EventArgs.HarvestArgs):
	var destination = Global.MANA_TARGET_LOCATION_PURPLE if args.purple else Global.MANA_TARGET_LOCATION_YELLOW
	blight_bubble_animation(tile, args, destination)
	on_yield_gained.emit(args)

func do_winter_clear():
	var blighted_tiles: Array[Tile] = []
	var reset_colors = $Tiles.get_children().any(func(tile): return !tile.purple)
	for tile: Tile in $Tiles.get_children():
		tile.do_winter_clear()
		tile.set_blight_targeted(false)
		tile.set_destroy_targeted(false)
		tile.lose_irrigate()
		if tile.blighted:
			blighted_tiles.append(tile)
		if reset_colors:
			tile.purple = tile.grid_location.x >= Constants.PURPLE_GTE_INDEX
			tile.update_purple_overlay()
	if Global.DIFFICULTY < Constants.DIFFICULTY_HEAL_SLOWER:
		remove_blight_from_all_tiles()
	else:
		blighted_tiles.shuffle()
		for i in range(0, blighted_tiles.size()):
			if i < ceil(float(blighted_tiles.size()) / 2.0):
				blighted_tiles[i].remove_blight()
	next_turn_effects.clear()

func spread(card, grid_position, size, shape):
	var targets = get_targeted_tiles(grid_position, card, size, shape, 0)
	targets.shuffle()
	var targeted_tile = use_card_on_targets(card, targets, true)
	if targeted_tile != null:
		do_animation(load("res://src/animation/spread.tres"), targeted_tile.grid_location)

func use_card_on_targets(card, targets, only_first):
	for target in targets:
		if not Helper.in_bounds(target):
			continue
		var target_tile = tiles[target.x][target.y]
		if not target_tile.card_can_target(card):
			continue
		if card.type == "SEED":
			effect_queue.append_array(target_tile.plant_seed_animate(card.copy()))
		elif card.type == "ACTION":
			use_action_card(card, Vector2(target.x, target.y))
		if only_first:
			return target_tile

func gain_energy(amount):
	on_energy_gained.emit(amount)

# Unused, moved to CardData
func preview_yield(card, targeted_tile: Tile):
	var yld_purple = 0.0
	var yld_yellow = 0.0
	var defer = card.get_effect("harvest_delay") != null
	if (card.get_effect("harvest") != null\
		or card.get_effect("harvest_delay") != null)\
		and targeted_tile.card_can_target(card):
		var harvest: EventArgs.HarvestArgs = targeted_tile.preview_harvest()
		harvest.yld = round(harvest.yld)
		var specific = EventArgs.SpecificArgs.new(targeted_tile)
		specific.harvest_args = harvest
		event_manager.notify_specific_args(EventManager.EventType.OnYieldPreview, specific)
		if harvest.purple:
			yld_purple += harvest.yld
		else:
			yld_yellow += harvest.yld
		defer = defer or harvest.delay
	var increase_yield = card.get_effect("increase_yield")
	if increase_yield != null:
		yld_purple *= 1.0 + increase_yield.strength
		yld_yellow *= 1.0 + increase_yield.strength
	return {
		"purple": round(yld_purple),
		"yellow": round(yld_yellow),
		"defer": defer
	}

func on_expand_farm():
	for tile in $Tiles.get_children():
		tile.do_active_check()

func destroy_blighted_tiles():
	for tile in $Tiles.get_children():
		if tile.blight_targeted == true and !tile.is_protected():
			tile.destroy()
			tile.set_blight_targeted(false)
		elif tile.destroy_targeted == true and !tile.is_protected():
			tile.destroy()

func use_card_random_tile(card: CardData, times: int):
	var tiles = []
	for tile: Tile in $Tiles.get_children():
		if tile.state == Enums.TileState.Empty && tile.not_destroyed():
			tiles.append(tile)
	tiles.shuffle()
	var locations = []
	if tiles.size() == 0:
		return
	for i in range(times):
		if i < tiles.size():
			locations.append(tiles[i].grid_location)
	use_card_on_targets(card, locations, false)

func use_card_unprotected_tile(card: CardData, times: int):
	var tiles = []
	for tile: Tile in $Tiles.get_children():
		if tile.state == Enums.TileState.Empty && !tile.is_protected() && tile.not_destroyed():
			tiles.append(tile)
	tiles.shuffle()
	var locations = []
	var i = 0
	if tiles.size() == 0:
		return
	while i < times and i < tiles.size():
		locations.append(tiles[i].grid_location)
		i += 1
	use_card_on_targets(card, locations, false)
	
func get_all_tiles() -> Array[Tile]:
	var result: Array[Tile] = []
	result.assign($Tiles.get_children())
	return result

func on_farm_tile_on_event(event_type: EventManager.EventType, specific_args):
	event_manager.notify_specific_args(event_type, specific_args)

func remove_blight_from_all_tiles():
	for tile in $Tiles.get_children():
		if tile.blighted:
			tile.remove_blight()

func blight_bubble_animation(tile: Tile, args: EventArgs.HarvestArgs, destination: Vector2):
	var bubbles = args.yld
	for i in range(bubbles):
		var sprite = Sprite2D.new()
		sprite.texture = load("res://assets/custom/PurpleMana.png") if args.purple else load("res://assets/custom/YellowMana.png")
		sprite.modulate.a = 0
		sprite.scale = Vector2.ZERO
		sprite.position = tile.position + Vector2(TILE_SIZE.x * randf(), TILE_SIZE.y * randf())
		sprite.z_index = 1
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var target_position = Vector2(destination)
		target_position.x += 200.0 if args.delay and args.purple else 0.0
		target_position += Vector2(-8 + 16 * randf(), -8 + 16 * randf())
		var time = Constants.MANA_MOVE_TIME + randf() * Constants.MANA_MOVE_VARIANCE
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "modulate:a", 1, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(sprite, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(sprite, "position", target_position, time).set_trans(Tween.TRANS_EXPO)
		tween.tween_callback(func():
			$Animations.remove_child(sprite))
		$Animations.add_child(sprite)

func _on_user_interface_farm_preview_hide() -> void:
	for tile: Tile in get_all_tiles():
		tile.hide_peek()

func _on_user_interface_farm_preview_show() -> void:
	for tile: Tile in get_all_tiles():
		tile.show_peek()

func _on_confirm_button_pressed() -> void:
	if hovered_tile != null:
		use_card(hovered_tile.grid_location)

func do_animation(spriteframes, grid_location):
	var anim = AnimatedSprite2D.new()
	anim.sprite_frames = spriteframes
	if grid_location != null:
		anim.position = TOP_LEFT + grid_location * Constants.TILE_SIZE + Constants.TILE_SIZE / 2
	else:
		anim.position = TOP_LEFT + Vector2(4, 4) * Constants.TILE_SIZE
	anim.scale = Constants.TILE_SIZE / Vector2(16, 16)
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var path: String = spriteframes.resource_path
	if path.contains("catalyze") or path.contains("downpour"):
		anim.position -= Vector2(0, Constants.TILE_SIZE.y / 2)
	add_child(anim)
	anim.play("default")
	anim.animation_finished.connect(func():
		remove_child(anim))
	print("Animation: " + spriteframes.resource_path)
