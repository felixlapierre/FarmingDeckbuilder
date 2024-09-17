extends CardData
class_name EarthWard

var callback: Callable
var event_type = EventManager.EventType.BeforeCardPlayed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if has_no_plant(tile):
				var harvest_args = EventArgs.HarvestArgs.new(self.strength, true, false)
				args.farm.gain_yield(tile, harvest_args)
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func has_no_plant(tile: Tile):
	return tile.state != Enums.TileState.Growing and tile.state != Enums.TileState.Mature and tile.state != Enums.TileState.Inactive

func copy():
	var new = EarthWard.new()
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true

func preview_yield(tile: Tile):
	var purple = 0
	if has_no_plant(tile):
		purple = self.strength
	return {
		"purple": purple,
		"yellow": 0,
		"defer": false
	}
