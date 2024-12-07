extends CustomEvent

var options

func _init():
	super._init("Great City of Deviro", "Description")
	var option1 = CustomEvent.Option.new("Opal (Knowledge)", null,\
		pick_element_cards_function("Knowledge"))
	var option2 = CustomEvent.Option.new("Quartz (Wind)", null,\
		pick_element_cards_function("Wind"))
	var option3 = CustomEvent.Option.new("Tourmaline (Time)", null,\
		pick_element_cards_function("Time"))
	var option4 = CustomEvent.Option.new("Sapphire (Water)", null, \
		pick_element_cards_function("Water"))
	var option5 = CustomEvent.Option.new("Emerald (Nature)", null, \
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
