extends Structure
class_name Lantern

var callback_cardplay

var event_type_cardplay = EventManager.EventType.BeforeCardPlayed

func _init():
	super()

func copy():
	var copy = Lantern.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback_cardplay = func(args: EventArgs):
		var tiles: Array[Tile] = []
		for neartile: Tile in args.farm.get_all_tiles():
			if Helper.is_nearby(neartile.grid_location, tile.grid_location)\
				and [Enums.TileState.Growing, Enums.TileState.Mature].has(neartile.state):
				tiles.append(neartile)
		tiles.shuffle()
		if tiles.size() > 0:
			tiles[0].add_yield(2)

	event_manager.register_listener(event_type_cardplay, callback_cardplay)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type_cardplay, callback_cardplay)
