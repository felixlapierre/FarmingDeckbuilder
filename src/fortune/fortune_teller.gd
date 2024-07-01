extends Node2D

var event_manager: EventManager
var data_fetcher = preload("res://src/cards/cards_database.gd")

var fortune_map = {}

var good_fortune: Fortune
var bad_fortune: Fortune

signal on_close

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer.position = Constants.VIEWPORT_SIZE / 2 - $PanelContainer.size / 2

func setup(p_event_manager: EventManager):
	event_manager = p_event_manager
	for fortune in data_fetcher.get_all_fortunes():
		if !fortune_map.has(fortune.type):
			fortune_map[fortune.type] = []
		fortune_map[fortune.type].append(fortune)

func create_fortunes():
	for type in Fortune.FortuneType.values():
		fortune_map[type].shuffle()
	good_fortune = fortune_map[Fortune.FortuneType.GoodFortune][0]
	if [4, 7, 10].has(event_manager.turn_manager.year+1):
		bad_fortune = fortune_map[Fortune.FortuneType.MajorBadFortune][0]
	else:
		bad_fortune = fortune_map[Fortune.FortuneType.MinorBadFortune][0]

	$PanelContainer/VBox/HBox/GoodFortune/VBox/Name.text = good_fortune.name
	$PanelContainer/VBox/HBox/GoodFortune/VBox/RichTextLabel.text = good_fortune.text
	
	$PanelContainer/VBox/HBox/BadFortune/VBox/Name.text = bad_fortune.name
	$PanelContainer/VBox/HBox/BadFortune/VBox/RichTextLabel.text = bad_fortune.text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func register_fortunes():
	if good_fortune != null:
		good_fortune.register_fortune(event_manager)
	if bad_fortune != null:
		bad_fortune.register_fortune(event_manager)

func unregister_fortunes():
	if good_fortune != null:
		good_fortune.unregister_fortune(event_manager)
	if bad_fortune != null:
		bad_fortune.unregister_fortune(event_manager)

func _on_click_out_button_pressed() -> void:
	on_close.emit()
