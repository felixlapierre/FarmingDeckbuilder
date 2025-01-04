extends Structure
class_name SparkShroom

var callback: Callable

var event_type = EventManager.EventType.BeforeTurnStart
var deathcap = preload("res://src/fortune/unique/deathcap.tres")

func _init():
	super()

func copy():
	var copy = SparkShroom.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	var shrooms_count = 5
	callback = func(args: EventArgs):
		var candidates: Array[Tile] = []
		for target_tile in args.farm.get_all_tiles():
			if !target_tile.is_destroyed() and target_tile.state == Enums.TileState.Empty and target_tile.structure == null and !target_tile.rock:
				candidates.append(target_tile)
		candidates.sort_custom(func(a: Tile, b: Tile):
			var adist = abs(a.grid_location.y - tile.grid_location.y) + abs(a.grid_location.x - tile.grid_location.x)
			var bdist = abs(b.grid_location.y - tile.grid_location.y) + abs(b.grid_location.x - tile.grid_location.x)
			return adist < bdist)
		for i in range(min(shrooms_count, candidates.size())):
			candidates[i].plant_seed_animate(deathcap)
		args.turn_manager.energy += 1
		tile.play_effect_particles()
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
