extends CardData
class_name GildedRose

@export var strength: float = 1.0

var callback: Callable
var event_type = EventManager.EventType.OnPlantHarvest
var my_tile

func copy():
	var new = GildedRose.new()
	new.assign(self)
	return new

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	my_tile = p_tile
	callback = func(args: EventArgs):
		var tile: Tile = args.specific.tile
		if tile == my_tile:
			var harvest_args = EventArgs.HarvestArgs.new(Global.GILDED_ROSE_TALLY, tile.purple, false)
			args.farm.gain_yield(tile, harvest_args)
			Global.GILDED_ROSE_TALLY += strength
	event_manager.register_listener(event_type, callback)
	event_manager.register_listener(EventManager.EventType.BeforeYearStart, func(args: EventArgs):
		Global.GILDED_ROSE_TALLY = 0.0)

func unregister_seed_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
