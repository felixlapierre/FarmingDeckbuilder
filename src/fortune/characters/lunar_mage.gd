extends MageAbility
class_name LunarMageFortune

var icon = preload("res://assets/card/temporal_rift.png")
static var MAGE_NAME = "Lunar Priest"
var event_type = EventManager.EventType.BeforeGrow
var event_callable: Callable

var event_type_allblue = EventManager.EventType.AfterYearStart
var allblue_callable: Callable

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Entire farm is blue. At the end of the turn, 70% of " + Helper.blue_mana() + "is converted to" + Helper.mana_icon(), 3, icon, 0.7)

func register_fortune(event_manager: EventManager):
	text = "Entire farm is blue. At the end of the turn, " + str(strength * 100) + "% of " + Helper.blue_mana() + "is converted to" + Helper.mana_icon()
	super.register_fortune(event_manager)
	Global.LUNAR_FARM = true
	allblue_callable = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			tile.purple = true
			tile.update_display()
	event_callable = func(args: EventArgs):
		if !args.turn_manager.flag_defer_excess:
			var excess = max(args.turn_manager.purple_mana - args.turn_manager.target_blight, 0)
			args.farm.gain_yield(args.farm.tiles[4][4], EventArgs.HarvestArgs.new(excess * strength, false, false))
	
	event_manager.register_listener(event_type_allblue, allblue_callable)
	event_manager.register_listener(event_type, event_callable)

func unregister_fortune(event_manager: EventManager):
	Global.LUNAR_FARM = false
	event_manager.unregister_listener(event_type, event_callable)
	event_manager.unregister_listener(event_type_allblue, allblue_callable)

func upgrade_power():
	strength = 0.85
	text = "Entire farm is blue. At the end of the turn, " + str(strength * 100) + "% of " + Helper.blue_mana() + "is converted to" + Helper.mana_icon()
