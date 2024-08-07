extends Fortune

var callable
var image = preload("res://assets/custom/CardFragment.png")

func _init() -> void:
	super("Librarian", FortuneType.GoodFortune, "+1 Card Fragment this year", 0, image)

func register_fortune(event_manager: EventManager):
	Global.SCROLL_FRAGMENTS += 1

func unregister_fortune(event_manager: EventManager):
	Global.SCROLL_FRAGMENTS -= 1
