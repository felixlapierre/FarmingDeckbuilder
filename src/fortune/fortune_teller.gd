extends Node2D

var event_manager: EventManager
var data_fetcher = preload("res://src/cards/cards_database.gd")
var fortune_display_scene = preload("res://src/fortune/fortune.tscn")

var fortune_map = {}
var size = 0

var current_fortunes: Array[Fortune] = []

signal on_close

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CenterContainer.custom_minimum_size = Constants.VIEWPORT_SIZE

func setup(p_event_manager: EventManager):
	event_manager = p_event_manager
	for fortune in data_fetcher.get_all_fortunes():
		if !fortune_map.has(fortune.type):
			fortune_map[fortune.type] = []
		fortune_map[fortune.type].append(fortune)

func create_fortunes():
	# Clear last week's fortunes
	current_fortunes.clear()
	for child in $CenterContainer/PanelContainer/VBox/Fortunes.get_children():
		$CenterContainer/PanelContainer/VBox/Fortunes.remove_child(child)
		
	# Ensure we get a random fortune
	for type in Fortune.FortuneType.values():
		fortune_map[type].shuffle()
	
	# Select the fortunes based on week
	if Global.DIFFICULTY < Constants.DIFFICULTY_MISFORTUNE:
		current_fortunes.append(get_fortune(Fortune.FortuneType.GoodFortune, 0))
		get_current_fortunes_regular()
	else:
		get_current_fortunes_misfortune()

	# Display the fortunes
	for fortune in current_fortunes:
		var display: Control = fortune_display_scene.instantiate()
		display.find_child("Name").text = fortune.name
		display.find_child("Description").text = fortune.text
		display.find_child("Texture").texture = fortune.texture
		$CenterContainer/PanelContainer/VBox/Fortunes.add_child(display)

func get_current_fortunes_regular():
	match event_manager.turn_manager.year + 1:
		2, 3, 5, 6:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 0))
		4:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 1))
		7:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 2))
		8, 9:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 1))
		10:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 3))
		11:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 0))
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 1))
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 3))
			
		_:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, randi_range(0, 3)))

func get_current_fortunes_misfortune():
	match event_manager.turn_manager.year + 1:
		2, 3:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 0))
		4:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 1))
		5:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 0))
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 0))
		6:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 1))
		7:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 0))
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 2))
		8:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 0))
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 1))
		9:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 1))
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 2))
		10:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 2))
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 3))
		11:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 0))
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 1))
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 2))
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, 3))
			
		_:
			current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, randi_range(0, 3)))

func add_bad_fortune(rank: int):
	current_fortunes.append(get_fortune(Fortune.FortuneType.BadFortune, rank))

func get_fortune(type: Fortune.FortuneType, rank: int):
	var options = []
	for fortune in fortune_map[type]:
		if fortune.rank == rank and !current_fortunes.has(fortune):
			options.append(fortune)
	options.shuffle()
	return options[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func register_fortunes():
	for fortune in current_fortunes:
		fortune.register_fortune(event_manager)

func unregister_fortunes():
	for fortune in current_fortunes:
		fortune.unregister_fortune(event_manager)

func _on_click_out_button_pressed() -> void:
	on_close.emit()
