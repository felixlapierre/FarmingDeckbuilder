extends MageAbility
class_name VoidMageFortune

var icon = preload("res://assets/structure/temporal_rift.png")

var strength = 2
var event_type = EventManager.EventType.BeforeTurnStart
var event_callable: Callable

func _init() -> void:
	super("Voidcaster", Fortune.FortuneType.GoodFortune, "At the start of the turn, gain " + str(strength) + Helper.blue_mana() + " per destroyed tile", 7, icon)

func register_fortune(event_manager: EventManager):
	event_callable = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.state == Enums.TileState.Destroyed or tile.state == Enums.TileState.Blighted:
				args.farm.gain_yield(tile, EventArgs.HarvestArgs.new(strength, true, false))
	event_manager.register_listener(event_type, event_callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, event_callable)
