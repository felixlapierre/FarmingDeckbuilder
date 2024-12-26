extends CustomEvent

func _init():
	super._init("Trader", "A merchant and her donkey visit your farm. This merchant has heard of your quest, and can spare a useful item to aid you.")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	var option1 = CustomEvent.Option.new("Trade for a Card", text_preview("Add a Card to your deck"), func():
		user_interface.pick_cards_event_rarity("common"))
	var option2 = CustomEvent.Option.new("Trade for an Enhance", text_preview("Enhance a card in your deck"), func():
		user_interface.pick_enhance_event("common"))
	var option3 = CustomEvent.Option.new("Trade for a Structure", text_preview("Build a Structure on your farm"), func():
		user_interface.pick_structure_event("common"))
	return [option1, option2, option3]

func check_prerequisites():
	return true
