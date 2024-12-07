extends CustomEvent

var options

func _init():
	super._init("Mastery", "Description")
	var option1 = CustomEvent.Option.new("Upgrade your Mage Power", null, func():
		user_interface.mage_fortune.upgrade_power()
		user_interface.create_fortune_display())
	#var option2 = CustomEvent.Option.new("Choose a new Mage Power", null,\
	#	func(): pass)

	options = [option1]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	return options

func check_prerequisites():
	return turn_manager.week > 7 and user_interface.mage_fortune.name != "Pyromancer" and user_interface.mage_fortune.name != "Water Mage"\
		and user_interface.mage_fortune.name != "Lost in Time"
