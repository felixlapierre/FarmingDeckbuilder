extends Fortune
class_name EndTurnRandomizeColors

var callable
var farm_ref: Farm

var kaleidoscope_texture = preload("res://assets/fortune/kaleidoscope0.png")
func _init() -> void:
	super("Kaleidoscope", FortuneType.BadFortune, "On turn start: Randomize color of tiles", 0, kaleidoscope_texture)

func register_fortune(event_manager: EventManager):
	callable = func(args):
		farm_ref = args.farm
		var tiles_ordered: Array[Tile] = []
		var tile_colors_randomized: Array[bool] = []
		for tile: Tile in farm_ref.get_all_tiles():
			if tile.state != Enums.TileState.Inactive and !tile.is_protected():
				tiles_ordered.append(tile)
		for tile: Tile in tiles_ordered:
			tile_colors_randomized.append(tile.purple)
		tile_colors_randomized.shuffle()
		for i in range(tiles_ordered.size()):
			tiles_ordered[i].purple = tile_colors_randomized[i]
			tiles_ordered[i].update_purple_overlay()
	event_manager.register_listener(EventManager.EventType.BeforeTurnStart, callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.BeforeTurnStart, callable)
