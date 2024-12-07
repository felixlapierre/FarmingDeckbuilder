extends CustomEvent

func _init():
	super._init("Dream of Emptiness", "You dream of walking through the woods, on a path illuminated by tiny glowing wisps, until you arrive at a yawning pit in a forest clearing. It offers to take away your most painful memories. ")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	var option1 = CustomEvent.Option.new("Offer a spell instead (Remove a card from your deck)", null, func():
		user_interface.remove_card_event()
	)
	var option2 = CustomEvent.Option.new("Embrace emptiness (Remove three random cards from your deck)", null, func():
		var deck = []
		deck.assign(user_interface.deck)
		deck.shuffle()
		user_interface.deck.erase(deck[0])
		user_interface.deck.erase(deck[1])
		user_interface.deck.erase(deck[2])
	)
	var option3 = CustomEvent.Option.new("Wake Up", null, func(): pass)
	return [option1, option2, option3]

func check_prerequisites():
	return true
