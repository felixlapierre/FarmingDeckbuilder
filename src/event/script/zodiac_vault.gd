extends CustomEvent

var curse = load("res://src/fortune/curses/dissociation.gd").new()

func _init():
	super._init("Zodiac Vault", "This description is blank for now, sorry!")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	var nodes: Array[Node] = []
	var curse_display = FortuneDisplay.instantiate()
	curse_display.setup(curse)
	nodes.append(curse_display)
	
	var option1 = CustomEvent.Option.new("Search the upper floors",\
	text_preview("Pick a Blessing to gain"), func():
		user_interface.pick_blessing("Pick a blessing to gain", [])
	)
	var option2 = CustomEvent.Option.new("Delve deep for treasure", nodes_preview("Pick 2 Blessings to gain. Gain Curse: Dissociation", nodes), func():
		user_interface.pick_blessing("Pick a blessing to gain", [])
		user_interface.pick_blessing("Pick a blessing to gain", [])
		user_interface._on_explore_on_fortune(curse)
	)
	return [option1, option2]

func check_prerequisites():
	return true
