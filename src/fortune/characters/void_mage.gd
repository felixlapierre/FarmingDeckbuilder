extends MageAbility
class_name VoidMageFortune

var icon = preload("res://assets/structure/temporal_rift.png")
static var MAGE_NAME = "Voidcaster"
var event_type = EventManager.EventType.BeforeTurnStart
var event_callable: Callable

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "At the start of the turn, gain 2" + Helper.blue_mana() + " per destroyed tile", 7, icon, 2.0)

func register_fortune(event_manager: EventManager):
	super.register_fortune(event_manager)
	event_callable = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.is_destroyed():
				args.farm.gain_yield(tile, EventArgs.HarvestArgs.new(strength, true, false))
	event_manager.register_listener(event_type, event_callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, event_callable)

func upgrade_power():
	strength = 4.0
	text = "At the start of the turn, gain " + str(strength) + Helper.blue_mana() + " per destroyed tile"
