extends CustomEvent

func _init():
	super._init("A Curious Seed", "As you relax under the shade of an oak tree, a small red squirrel approaches you and deposits a small object at your feet. At first it appears to be a small pebble, but closer inspection reveals that it is a seed. It is gray and hard - you doubt it could grow in its current condition. It seems rude to refuse a gift, even from such a humble creature.")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	var option1 = CustomEvent.Option.new("Accept the seed", null, func():
		user_interface.deck.append(load("res://src/event/unique/magic_seed.tres"))
	)
	var option2 = CustomEvent.Option.new("Refuse the squirrel's gift", null, func(): pass)
	return [option1, option2]

func check_prerequisites():
	return true
