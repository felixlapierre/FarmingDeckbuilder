extends CardData
class_name YieldToRandomBlight

var callback: Callable
var event_type = EventManager.EventType.BeforeCardPlayed

var blighroot_seed = load("res://src/fortune/unique/blightroot.tres")

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		var eligible: Array[Tile] = []
		var eligible_blightroot: Array[Tile] = []
		for tile: Tile in args.farm.get_all_tiles():
			if tile.state == Enums.TileState.Growing or tile.state == Enums.TileState.Mature:
				eligible.append(tile)
			if tile.state == Enums.TileState.Empty and !tile.is_protected():
				eligible_blightroot.append(tile)
		eligible.shuffle()
		eligible_blightroot.shuffle()
		var i = 0
		while i < eligible.size() and i < args.turn_manager.blight_damage:
			eligible[i].add_yield(self.strength)
			i += 1
		i = 0
		while i < eligible_blightroot.size() and i < args.turn_manager.blight_damage:
			eligible_blightroot[i].plant_seed_animate(blighroot_seed)
			i += 1
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = YieldToRandomBlight.new()
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true
