extends Node2D

var player_deck
var tooltip

var ExplorePoint = load("res://src/ui/menus/explore_point.tscn")
var PickOption = preload("res://src/ui/pick_option.tscn")
var cards_database = preload("res://src/cards/cards_database.gd")
var SelectCard = preload("res://src/cards/select_card.tscn")

signal apply_upgrade
signal on_structure_select
signal on_event

var explores = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setup(deck, p_tooltip):
	player_deck = deck
	tooltip = p_tooltip

func create_explore(p_explores):
	explores = p_explores
	var DIST = 250
	var positions = [
		Vector2(-DIST, -DIST),
		Vector2(-DIST, 0),
		Vector2(-DIST, DIST),
		Vector2(0, -DIST),
		Vector2(0, DIST),
		Vector2(DIST, -DIST),
		Vector2(DIST, 0),
		Vector2(DIST, DIST)
	]
	positions.shuffle()
	# Add card
	create_point("Gain Card", positions.pop_front(), func():
		add_card())
	
	# Event
	create_point("Event", positions.pop_front(), func():
		on_event.emit())
	
	# Remove card
	create_point("Remove Card", positions.pop_front(), func():
		select_card_to_remove())
	
	# Structure
	create_point("Structure", positions.pop_front(), func():
		add_structure())
	
	# Enhance
	create_point("Enhance Card", positions.pop_front(), func():
		select_enhance())

func use_explore(node):
	node.disable()
	explores -= 1
	if explores == 0:
		for child in $Points.get_children():
			child.disable()
	$CenterContainer/PanelContainer/VBox/HBox/Label.text = "Explorations Remaining: " + str(explores)

func create_point(name: String, pos: Vector2, callback: Callable):
	var point: ExplorePoint = ExplorePoint.instantiate()
	point.setup(name)
	point.position = pos
	point.on_select.connect(func():
		use_explore(point)
		visible = false
		callback.call())
	$Points.add_child(point)

func add_card():
	var pick_option_ui = PickOption.instantiate()
	var cards;
	if Global.FARM_TYPE == "WILDERNESS":
		cards = cards_database.get_random_action_cards(null, 5)
	else:
		cards = cards_database.get_random_cards(null, 5)
	add_sibling(pick_option_ui)
	var prompt = "Pick a card to add to your deck"

	pick_option_ui.setup(prompt, cards, func(selected):
		player_deck.append(selected.card_info)
		remove_sibling(pick_option_ui)
		visible = true, func():
			remove_sibling(pick_option_ui)
			visible = true)

func select_card_to_remove():
	var select_card = SelectCard.instantiate()
	select_card.tooltip = tooltip
	select_card.size = Constants.VIEWPORT_SIZE
	select_card.z_index = 2
	select_card.theme = load("res://assets/theme_large.tres")
	select_card.disable_cancel()
	select_card.select_callback = func(card_data):
		remove_sibling(select_card)
		player_deck.erase(card_data)
		visible = true
	add_sibling(select_card)
	select_card.do_card_pick(player_deck, "Select a card to remove")

func select_enhance():
	var enhances = cards_database.get_random_enhance("", 3, false)
	var pick_option_ui = PickOption.instantiate()
	add_sibling(pick_option_ui)
	var prompt = "Pick an enhance to apply"
	pick_option_ui.setup(prompt, enhances, func(selected):
		select_card_to_enhance(selected)
		remove_sibling(pick_option_ui),
		func():
			remove_sibling(pick_option_ui)
			visible = true)

func select_card_to_enhance(enhance: Enhance):
	var select_card = SelectCard.instantiate()
	select_card.tooltip = tooltip
	select_card.size = Constants.VIEWPORT_SIZE
	select_card.z_index = 2
	select_card.theme = load("res://assets/theme_large.tres")
	select_card.disable_cancel()
	select_card.select_callback = func(card_data: CardData):
		remove_sibling(select_card)
		var new_card = card_data.apply_enhance(enhance)
		player_deck.erase(card_data)
		player_deck.append(new_card)
		visible = true
	add_sibling(select_card)
	select_card.do_enhance_pick(player_deck, enhance, "Select a card to enhance")
	
func add_structure():
	var structures = cards_database.get_random_structures(3)
	var pick_option_ui = PickOption.instantiate()
	add_sibling(pick_option_ui)
	var prompt = "Pick a structure to add to your farm"
	var on_pick = func(selected):
		remove_sibling(pick_option_ui)
		on_structure_select.emit(selected, func():
			visible = true)
	var on_cancel = func(): 
		remove_sibling(pick_option_ui)
		visible = true
	pick_option_ui.setup(prompt, structures, on_pick, on_cancel)

func remove_sibling(node):
	$'../'.remove_child(node)

func _on_close_pressed():
	visible = false
