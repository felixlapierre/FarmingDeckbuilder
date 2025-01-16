extends CardData
class_name Propagation

var callback: Callable
var event_type = EventManager.EventType.OnActionCardUsed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		var options: Array[Tile] = []
		var target_tile: Tile = args.specific.tile
		for loc in Helper.get_tile_shape(8, Enums.CursorShape.Elbow):
			var target = target_tile.grid_location + loc
			if Helper.in_bounds(target):
				var tile: Tile = args.farm.tiles[target.x][target.y]
				if tile.card_can_target(target_tile.seed):
					options.append(tile)
		options.shuffle()
		var amount = target_tile.seed.size + strength
		for i in range(min(amount, options.size())):
			var target: Tile = options[i]
			target.plant_seed_animate(target_tile.seed.copy())
			args.farm.do_animation(load("res://src/animation/spread.tres"), target.grid_location)
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = Propagation.new()
	new.assign(self)
	return new

func get_description() -> String:
	var desc: String = super.get_description()
	if self.strength > 0:
		return desc.replace("Size", "Size, [color=aqua]plus " + str(self.strength) + "[/color]")
	return desc

func can_strengthen_custom_effect():
	return true
