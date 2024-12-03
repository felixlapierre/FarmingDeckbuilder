extends Structure
class_name EnergyFullFarm

var callback: Callable

var event_type = EventManager.EventType.BeforeTurnStart

func _init():
	super()

func copy():
	var copy = EnergyFullFarm.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		var active = true
		for t in args.farm.get_all_tiles():
			if t.state == Enums.TileState.Empty and t.structure == null and !t.is_destroyed():
				active = false
				break
		if active:
			args.turn_manager.energy += 1
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
