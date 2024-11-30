extends MageAbility
class_name IceMageFortune

var icon = preload("res://assets/card/frostcut.png")
static var MAGE_NAME = "Frost Witch"
func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Your hand is not discarded at the end of the turn. Set maximum hand size to 8.", 1, icon, 8.0)

func register_fortune(event_manager: EventManager):
	super.register_fortune(event_manager)
	Global.END_TURN_DISCARD = false
	Global.MAX_HAND_SIZE = int(strength)

func unregister_fortune(event_manager: EventManager):
	Global.END_TURN_DISCARD = true
	Global.MAX_HAND_SIZE = 10

func upgrade_power():
	strength = 10.0
	Global.MAX_HAND_SIZE = int(strength)
	text = "Your hand is not discarded at the end of the turn"
	
	
