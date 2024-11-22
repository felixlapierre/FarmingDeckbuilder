extends CardData
class_name GrowWatered

var callback: Callable
var event_type = EventManager.EventType.BeforeCardPlayed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		do_watered(args, func(tile):
			args.farm.do_animation(load("res://src/animation/frames/flow_sf.tres"), tile.grid_location))
		await args.farm.get_tree().create_timer(delay).timeout
		do_watered(args, func(tile):
			args.farm.effect_queue.append_array(tile.grow_one_week()))
					
	event_manager.register_listener(event_type, callback)

func do_watered(args: EventArgs, call: Callable):
	for tile in args.farm.get_all_tiles():
		if tile.irrigated and tile.state == Enums.TileState.Growing:
			for i in range(strength):
				call.call(tile)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = GrowWatered.new()
	new.assign(self)
	return new

func get_description() -> String:
	var desc = super.get_description()
	return desc.replace("{$STRENGTH_WEEKS}", str(strength) + (" weeks" if strength > 1 else " week"))

func can_strengthen_custom_effect():
	return true
