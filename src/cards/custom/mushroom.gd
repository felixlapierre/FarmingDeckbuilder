extends CardData
class_name Mushroom

@export var strength: float

var tile: Tile
var callback: Callable

func _init(p_name = "PlaceholderCardName", p_rarity = "common", p_cost = 1, p_yld = 1,\
	p_time = 1, p_size = 1, p_text = "", p_texture = null, p_seed_texture = 1, p_targets = [], p_effects = [], p_strength: float = 1.0) -> void:
	super("SEED", p_name, p_rarity, p_cost, p_yld, p_time, p_size, p_text, p_texture, p_seed_texture, p_targets, p_effects)
	strength = p_strength

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	tile = p_tile
	callback = func(args: EventArgs):
		var destroyed_tile: Tile = args.specific.tile
		if destroyed_tile.current_yield > 0:
			tile.add_yield(destroyed_tile.current_yield * strength)
	event_manager.register_listener(EventManager.EventType.OnPlantDestroyed, callback)

func unregister_seed_events(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.OnPlantDestroyed, callback)

func copy():
	var n_targets = []
	for target in targets:
		n_targets.append(target)
	var n_effects = []
	for effect in effects:
		n_effects.append(effect.copy())
	
	return Mushroom.new(name, rarity, cost, yld, time, size, text, texture, seed_texture, n_targets, n_effects, strength)
