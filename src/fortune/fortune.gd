extends Resource
class_name Fortune

enum FortuneType {
	# Bad fortunes
	Weeds,
	Creeping,
	Destroy,
	Swap,
	# Good fortunes
	ReduceRitualTarget
}

@export var name: String
@export var type: FortuneType
@export var text: String

var callback: Callable

func _init(p_name = "", p_type = FortuneType.Weeds, p_text = ""):
	name = p_name
	type = p_type
	text = p_text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func register_fortune(event_manager: EventManager):
	match type:
		FortuneType.Weeds:
			weeds(event_manager)
		FortuneType.ReduceRitualTarget:
			reduce_ritual_target(event_manager)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_on_year_start(callback)

func weeds(event_manager: EventManager):
	callback = func(farm: Farm, turn_manager: TurnManager):
		print("Weeds callback")
		var card: CardData = load("res://src/fortune/unique/weed.tres")
		farm.use_card_random_tile(card, 4)
	event_manager.register_on_year_start(callback)

func reduce_ritual_target(event_manager: EventManager):
	callback = func(farm: Farm, turn_manager: TurnManager):
		print("Reduce ritual target callback")
		turn_manager.ritual_counter -= 20
	event_manager.register_on_year_start(callback)
