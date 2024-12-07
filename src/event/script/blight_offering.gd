extends CustomEvent

func _init():
	super._init("Blight Offering", "You see visions of a beautiful tapestry of purple thorns and blood-gorged roots. The Blight offers you some of its power in hopes that it may convince you to set aside your quest.\n\nIt's an obvious trap, but you could use the blight's power against it, if you dare.")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	var option1 = CustomEvent.Option.new("Accept the offering", null, func():
		user_interface._on_upgrade_shop_on_upgrade(Upgrade.new(Upgrade.UpgradeType.GainBlight))
		user_interface.pick_cards_event(cards_database.get_element_cards("Blight"))
	)
	var option2 = CustomEvent.Option.new("Reject the offering", null, func():
		user_interface._on_upgrade_shop_on_upgrade(Upgrade.new(Upgrade.UpgradeType.RemoveBlight)))
	return [option1, option2]

func check_prerequisites():
	return turn_manager.blight_damage > 0 and turn_manager.blight_damage < Global.MAX_BLIGHT - 1
