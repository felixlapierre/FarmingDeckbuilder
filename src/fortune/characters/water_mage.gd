extends MageAbility
class_name WaterMage

var icon = preload("res://assets/mage/water_mage.png")
static var MAGE_NAME = "Water Mage"
func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Watered tiles cannot be targeted by the Blight", 2, icon)

func register_fortune(event_manager: EventManager):
	super.register_fortune(event_manager)
	Global.IRRIGATE_PROTECTED = true

func unregister_fortune(event_manager: EventManager):
	Global.IRRIGATE_PROTECTED = false

func update_text():
	text = "Watered tiles cannot be targeted by the Blight"
