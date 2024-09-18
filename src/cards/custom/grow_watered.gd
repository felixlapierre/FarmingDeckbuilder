extends CardData
class_name GrowWatered

var callback: Callable
var event_type = EventManager.EventType.BeforeCardPlayed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.irrigated and tile.state == Enums.TileState.Growing:
				for i in range(strength):
					args.farm.effect_queue.append_array(tile.grow_one_week())
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = WaterWard.new()
	new.assign(self)
	return new

func get_description() -> String:
	var desc = super.get_description()
	return desc.replace("{$STRENGTH_WEEKS}", str(strength) + (" weeks" if strength > 1 else "week"))

func can_strengthen_custom_effect():
	return true
