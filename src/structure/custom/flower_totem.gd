extends Structure

class_name FlowerTotem
var callback: Callable

var event_type = EventManager.EventType.BeforeYearStart
var wildflower = preload("res://src/fortune/unique/wildflower.tres")

func _init():
	super()

func copy():
	var copy = FlowerTotem.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		var targets = Helper.get_tile_shape(8, Enums.CursorShape.Elbow)
		for t in targets:
			var target = tile.grid_location + t
			var inbounds = Helper.in_bounds(target)
			if inbounds:
				var target_tile: Tile = args.farm.tiles[target.x][target.y]
				var cantarget = target_tile.card_can_target(wildflower)
				if cantarget:
					target_tile.plant_seed_animate(wildflower)
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
