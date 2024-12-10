extends CardData
class_name Propagation

var callback: Callable
var event_type = EventManager.EventType.OnActionCardUsed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		var effect = Effect.new("spread", args.specific.tile.seed.size + strength)
		effect.card = args.specific.tile.seed
		args.farm.perform_effect(effect, args.specific.tile)
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
		return desc.replace("size", "size, plus " + str(self.strength))
	return desc

func can_strengthen_custom_effect():
	return true
