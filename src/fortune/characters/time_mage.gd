extends MageAbility
class_name TimeMageFortune

var icon = preload("res://assets/custom/Time32.png")
static var MAGE_NAME = "Lost in Time"
var event_type = EventManager.EventType.AfterYearStart
var event_callable: Callable

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Add Regrow 3 and +1 [img]res://assets/custom/Time32.png[/img] week of grow time to all seeds. Add Time Bubble to your deck.", 8, icon, 2.0)
	modify_deck_callback = func(deck: Array[CardData]):
		deck.append(load("res://src/cards/data/action/time_bubble.tres"))

func register_fortune(event_manager: EventManager):
	super.register_fortune(event_manager)
	event_callable = func(args: EventArgs):
		for card: CardData in args.cards.deck_cards:
			apply_time(card)
		for card: CardData in args.cards.get_hand_info():
			apply_time(card)
		args.cards.update_hand_display()
	event_manager.register_listener(event_type, event_callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, event_callable)

func apply_time(card: CardData):
	if card.type == "SEED":
		var regrow = card.get_effect("plant")
		if regrow == null:
			card.effects.append(Effect.new("plant", 3, "harvest"))
		else:
			regrow.strength += 3
		card.time += 1
func upgrade_power():
	strength = 4.0
	text = ""
