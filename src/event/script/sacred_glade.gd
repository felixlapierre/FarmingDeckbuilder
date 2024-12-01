extends CustomEvent

var statue = load("res://src/structure/data/statue_of_grace.tres")

func _init():
	super._init("Sacred Glade", "Description")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	var option1 = CustomEvent.Option.new("Bring the statue back to your farm (Gain Structure: Statue of Grace)", null, func():
		user_interface._on_shop_on_structure_place(statue, func(): pass)
		user_interface.CancelStructure.visible = false
	)
	var option2 = CustomEvent.Option.new("Clean the statue and leave a gift basket (Gain 2 Favor)", null, func():
		user_interface.shop.player_money += 2
	)
	return [option1, option2]

func check_prerequisites():
	return turn_manager.blight_damage == 0 and turn_manager.week > 3
