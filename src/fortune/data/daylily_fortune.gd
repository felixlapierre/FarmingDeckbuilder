extends Fortune
class_name DaylilyFortune

var callback: Callable
var event_type = EventManager.EventType.BeforeYearStart
var daylily = preload("res://src/fortune/unique/daylily.tres")
var daylily_texture = preload("res://assets/fortune/daylily_fortune.png")

func _init() -> void:
	super("Daylilies", FortuneType.GoodFortune, "Add 2 Daylilies to your deck for this year", 0, daylily_texture)

func register_fortune(event_manager: EventManager):
	callback = add_daylily
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func add_daylily(args: EventArgs):
	args.cards.deck_cards.append(daylily.copy())
	args.cards.deck_cards.append(daylily.copy())
