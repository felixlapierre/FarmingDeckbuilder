extends CardData
class_name WaterRite

var callback: Callable
var event_type = EventManager.EventType.BeforeCardPlayed
var turn_end = EventManager.EventType.AfterGrow
var turn_end_callback: Callable
var year_start = EventManager.EventType.BeforeYearStart

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		var card: CardData = args.specific.play_args.card
		if card.type == "SEED":
			for tile in args.farm.get_all_tiles():
				if tile.irrigated and tile.state == Enums.TileState.Empty:
					tile.plant_seed_animate(card.copy())
	turn_end_callback = func(args: EventArgs):
		event_manager.unregister_listener(event_type, callback)
		event_manager.unregister_listener(turn_end, turn_end_callback)
		event_manager.unregister_listener(year_start, turn_end_callback)
	event_manager.register_listener(event_type, callback)
	event_manager.register_listener(turn_end, turn_end_callback)
	event_manager.register_listener(year_start, turn_end_callback)

func unregister_events(event_manager: EventManager):
	#event_manager.unregister_listener(event_type, callback)
	pass

func copy():
	var new = WaterRite.new()
	new.assign(self)
	return new
