extends CustomEvent

func _init():
	super._init("Trader", "A merchant and her donkey visit your farm. This merchant has heard of your quest, and brought a selection of rare spells from Rudania City")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	var option1 = CustomEvent.Option.new("Pick a Rare card to add to your deck", null, func():
		user_interface.pick_cards_event_rarity("rare"))
	return [option1]

func check_prerequisites():
	return true
