extends Fortune

var callable
var image = preload("res://assets/custom/EnergyFrag.png")

func _init() -> void:
	super("Energised", FortuneType.GoodFortune, "+1 Energy Fragment this year", 0, image)

func register_fortune(event_manager: EventManager):
	Global.ENERGY_FRAGMENTS += 1

func unregister_fortune(event_manager: EventManager):
	Global.ENERGY_FRAGMENTS -= 1
