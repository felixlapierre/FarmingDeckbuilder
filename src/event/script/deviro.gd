extends CustomEvent

var options

func _init():
	super._init("Great City of Deviro", \
	"As your struggle agains the Blight grows more difficult, you attempt a divination to locate any sources of power that might help make you stronger. Your scrying leads you to a ruined, overgrown city in the heart of the forest.\n
	At the center of the city is a huge pyramid. Nestled at its peak is a complex mechanism of gears, metal, mirrors and gemstones. Once, this was used to help mage circles cast powerful spells. Now, most of its parts have been pilfered and stolen.\n
	There remain a handful of gemstones left untouched in the array. You can faintly feel remnants of elemental energy emanating from each one.")
	var option1 = CustomEvent.Option.new("Consume the Opal gemstone (Knowledge)", null,\
		pick_element_cards_function("Knowledge"))
	var option2 = CustomEvent.Option.new("Consume the Quartz gemstone (Wind)", null,\
		pick_element_cards_function("Wind"))
	var option3 = CustomEvent.Option.new("Consume the Tourmaline gemstone (Time)", null,\
		pick_element_cards_function("Time"))
	var option4 = CustomEvent.Option.new("Consume the Sapphire gemstone (Water)", null, \
		pick_element_cards_function("Water"))
	var option5 = CustomEvent.Option.new("Consume the Emerald gemstone (Nature)", null, \
		pick_element_cards_function("Nature"))
	var opts = [option1, option2, option3, option4, option5]
	opts.shuffle()
	options = opts.slice(0, 3)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	return options

func pick_element_cards_function(element: String):
	return func():
		var cards: Array = cards_database.get_element_cards(element)
		cards.shuffle()
		user_interface.pick_cards_event(cards.slice(0, 3))

func check_prerequisites():
	return turn_manager.year > 4
