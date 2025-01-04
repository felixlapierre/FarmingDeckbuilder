extends Fortune
class_name NativeSeed

var seed
var icon = preload("res://assets/fortune/wildflowers-fortune.png")
var callback
var event_type = EventManager.EventType.BeforeYearStart

func _init(p_seed = null) -> void:
	super("Native Seed", Fortune.FortuneType.GoodFortune, "Start with the Native Seed planted on your farm", 0, icon, 1.0)
	seed = p_seed

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		args.farm.use_card_random_tile(seed.copy(), seed.size)
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func save_data():
	var data = super.save_data()
	data.seed = seed.save_data()
	return data

func load_data(data: Dictionary):
	super.load_data(data)
	seed = load(data.seed.path).new().load_data(data.seed)
	texture = seed.texture
	
