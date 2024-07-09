extends Fortune

var callable
var farm_ref: Farm

func _init() -> void:
	super("Kaleidoscope 3", FortuneType.BadFortune, "Randomize purple and yellow zones at end of turn", 3)

func register_fortune(event_manager: EventManager):
	callable = func(args):
		farm_ref = args.farm
		var tiles_ordered: Array[Tile] = []
		var tile_colors_randomized: Array[bool] = []
		for tile: Tile in farm_ref.get_all_tiles():
			if tile.state != Enums.TileState.Inactive:
				tiles_ordered.append(tile)
		for tile: Tile in tiles_ordered:
			tile_colors_randomized.append(tile.purple)
		tile_colors_randomized.shuffle()
		for i in range(tiles_ordered.size()):
			tiles_ordered[i].purple = tile_colors_randomized[i]
			tiles_ordered[i].update_purple_overlay()
	event_manager.register_listener(EventManager.EventType.OnTurnEnd, callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.OnTurnEnd, callable)
	if farm_ref != null:
		for tile: Tile in farm_ref.get_node("Tiles").get_children():
			tile.purple = tile.grid_location.x >= Constants.PURPLE_GTE_INDEX
			tile.update_purple_overlay()
