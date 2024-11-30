extends CustomEvent

var options

func _init():
	super._init("Chaos Surge", "Description")
	var option1 = CustomEvent.Option.new("Choose a card from your deck to Transform", null, func():
		user_interface.pick_card_from_deck_event("Choose a card to Transform", func(card_data):
			user_interface.deck.erase(card_data)
			var new_card = cards_database.get_random_cards(null, 1)
			user_interface.deck.append_array(new_card)))

	var option2 = CustomEvent.Option.new("Transform all cards in your deck", null, func(): 
		ChaosMageFortune.randomize_deck(user_interface.deck))

	options = [option1, option2]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	return options

func check_prerequisites():
	return user_interface.mage_fortune.name != "Pyromancer" and user_interface.mage_fortune.name != "Water Mage"
