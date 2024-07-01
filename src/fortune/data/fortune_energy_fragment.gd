extends Fortune

var callable

func _init() -> void:
	super("Energised", FortuneType.GoodFortune, "+1 Energy Fragment this year")

func register_fortune(event_manager: EventManager):
	Global.ENERGY_FRAGMENTS += 1

func unregister_fortune(event_manager: EventManager):
	Global.ENERGY_FRAGMENTS -= 1
