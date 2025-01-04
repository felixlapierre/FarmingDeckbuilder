extends Fortune
class_name WinterBlessing

var icon = preload("res://assets/fortune/snowflake.png")
var callback
var event_type = EventManager.EventType.BeforeTurnStart

func _init() -> void:
	super("Winter's Blessing", Fortune.FortuneType.GoodFortune, "Gain 100[img]res://assets/custom/YellowMana.png[/img] on the first week of Winter", 0, icon, 1.0)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		if args.turn_manager.week == Global.WINTER_WEEK:
			args.farm.gain_yield(args.farm.tiles[0][0], EventArgs.HarvestArgs.new(100, false, false))
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
