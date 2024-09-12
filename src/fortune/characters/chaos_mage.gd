extends MageAbility
class_name ChaosMageFortune

var icon = preload("res://assets/custom/Focus.png")
static var MAGE_NAME = "Spawn of Chaos"

var event_type = EventManager.EventType.BeforeCardPlayed
var event_callable: Callable

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Randomize starting deck", 5, icon)
	modify_deck_callback = func(deck: Array[CardData]):
		var scythes = []
		var seeds = []
		var actions = []
		for card in DataFetcher.get_all_cards():
			if card.type == "SEED":
				seeds.append(card)
			elif card.get_effect("harvest") != null or card.get_effect("harvest_delay") != null:
				scythes.append(card)
			else:
				actions.append(card)
		var new_deck = []
		for card in deck:
			var replacement_card
			if card.type == "SEED":
				replacement_card = seeds[randi_range(0, seeds.size() - 1)]
			elif card.name == "Scythe":
				replacement_card = scythes[randi_range(0, scythes.size() - 1)]
			else:
				replacement_card = actions[randi_range(0, actions.size() - 1)]
			new_deck.append(replacement_card)
		deck.clear()
		deck.append_array(new_deck)
