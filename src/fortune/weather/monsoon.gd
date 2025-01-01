extends Fortune
class_name MonsoonWeather

var display_texture = preload("res://assets/card/downpour.png")
var rain = load("res://src/animation/frames/downpour_sf.tres")
func _init() -> void:
	super("Monsoon", Fortune.FortuneType.GoodFortune, "For this turn, all tiles are considered to be Watered", 0, display_texture, strength)

func register_fortune(event_manager: EventManager):
	Global.ALL_WATERED = true
	for tile in event_manager.farm.get_all_tiles():
		event_manager.farm.do_animation(rain, tile.grid_location)

func unregister_fortune(event_manager: EventManager):
	Global.ALL_WATERED = false
