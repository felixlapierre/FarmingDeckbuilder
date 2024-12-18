extends Structure
class_name EnergyFullFarm

var callback: Callable
var callback2: Callable

var event_type = EventManager.EventType.BeforeTurnStart
var event_type2 = EventManager.EventType.AfterCardPlayed

var energy_flag = false

func _init():
	super()

func copy():
	var copy = EnergyFullFarm.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		if farm_is_full(args):
			args.turn_manager.energy += 1
			tile.play_effect_particles()
			energy_flag = true
		else:
			energy_flag = false
	callback2 = func(args: EventArgs):
		if !energy_flag and farm_is_full(args):
			args.turn_manager.energy += 1
			tile.play_effect_particles()
			args.user_interface.update()
			energy_flag = true
	event_manager.register_listener(event_type, callback)
	event_manager.register_listener(event_type2, callback2)

func farm_is_full(args: EventArgs):
	for t in args.farm.get_all_tiles():
		if t.state == Enums.TileState.Empty and t.structure == null and !t.is_destroyed():
			print("farm not full")
			return false
	print("farm full")
	return true
	
func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
	event_manager.register_listener(event_type2, callback2)
