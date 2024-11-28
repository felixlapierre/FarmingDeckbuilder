extends CustomEvent

func _init():
	super._init("Vessel Stone", "Description")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	var option1 = CustomEvent.Option.new("Draw the boundless energy of the Vessel Stone", null, func():
		user_interface.pick_enhance_event("rare")
	)
	return [option1]

func check_prerequisites():
	return true# turn_manager.week > 6
