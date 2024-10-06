extends CardData
class_name DeferPurple

var callback: Callable
var event_type = EventManager.EventType.OnPlantHarvest
var my_tile

func copy():
	var new = DeferPurple.new()
	new.assign(self)
	return new

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	my_tile = p_tile
	callback = func(args: EventArgs):
		var tile: Tile = args.specific.tile
		if tile == my_tile:
			tile.play_effect_particles()
	event_manager.register_listener(event_type, callback)

func unregister_seed_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func get_yield(tile: Tile) -> EventArgs.HarvestArgs:
	var harvest_args: EventArgs.HarvestArgs = super.get_yield(tile)
	harvest_args.delay = true
	return harvest_args
