extends CardData
class_name BleedingHeart

var tile: Tile
var callback: Callable

var event_type = EventManager.EventType.BeforeTurnStart

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.seed != null and ["Dark Rose", "Daylily", "Sunflower", "Marigold", "Hyacinth", "Gilded Rose", "Blightrose", "Iris", "Lotus", "Water Lily"].has(tile.seed.name):
				tile.add_yield(strength)
	event_manager.register_listener(event_type, callback)

func unregister_seed_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = BleedingHeart.new();
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true
