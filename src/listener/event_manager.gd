extends Node
class_name EventManager

var farm: Farm
var turn_manager: TurnManager
var cards: Cards

var on_year_start_listeners: Array[Callable] = []
var on_turn_end_listeners: Array[Callable] = []

var listeners: Dictionary = {}

enum EventType {
	# Time-based triggers
	BeforeYearStart,
	AfterYearStart,
	BeforeTurnStart,
	BeforeGrow,
	AfterGrow,
	OnTurnEnd,
	# Game action triggers
	OnPlantPlanted,
	OnPlantGrow,
	OnPlantHarvest,
	OnPlantDestroyed,
	BeforeCardPlayed,
	AfterCardPlayed,
	OnTileDestroyed,
	OnActionCardUsed,
	OnYieldPreview,
	OnPickCard,
	OnCardBurned
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for type in EventType.values():
		listeners[type] = []

func setup(p_farm: Farm, p_turn_manager: TurnManager, p_cards: Cards):
	farm = p_farm
	turn_manager = p_turn_manager
	cards = p_cards

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func register_listener(event_type: EventType, callback: Callable):
	listeners[event_type].append(callback)

func unregister_listener(event_type: EventType, callback: Callable):
	listeners[event_type].erase(callback)

func notify(event_type: EventType):
	for listener in listeners[event_type]:
		listener.call(get_event_args(null))

func notify_specific_args(event_type: EventType, specific_args: EventArgs.SpecificArgs):
	for listener in listeners[event_type]:
		if !listener.is_null():
			listener.call(get_event_args(specific_args))

func get_event_args(spec):
	return EventArgs.new(farm, turn_manager, cards, spec)
