extends CardData
class_name Puffshroom

var tile: Tile
var callback: Callable

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	tile = p_tile
	callback = func(args: EventArgs):
		if tile.state == Enums.TileState.Mature and randf() > strength:
			args.farm.effect_queue.append_array(tile.harvest(false))
			args.farm.process_effect_queue()
	event_manager.register_listener(EventManager.EventType.BeforeTurnStart, callback)

func unregister_seed_events(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.BeforeTurnStart, callback)

func get_description() -> String:
	var descr: String = super.get_description()
	return descr.replace("{STR_PER}", str(self.strength * 100))

func copy():
	var new = Puffshroom.new();
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true
