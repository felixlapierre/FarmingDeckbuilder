extends CardData
class_name Puffshroom

var tile: Tile
var callback: Callable

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	tile = p_tile
	callback = func(args: EventArgs):
		if p_tile.state == Enums.TileState.Mature:
			args.farm.effect_queue.append_array(p_tile.harvest(false))
			args.farm.process_effect_queue()
	event_manager.register_listener(EventManager.EventType.BeforeTurnStart, callback)

func unregister_seed_events(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.BeforeTurnStart, callback)

func copy():
	var new = Puffshroom.new();
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return false
