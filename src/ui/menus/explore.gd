extends Node2D

var player_deck
var tooltip

var ExplorePoint = load("res://src/ui/menus/explore_point.tscn")
var PickOption = preload("res://src/ui/pick_option.tscn")
var cards_database = preload("res://src/cards/cards_database.gd")
var SelectCard = preload("res://src/cards/select_card.tscn")

signal apply_upgrade
signal on_structure_select
signal on_expand
signal on_event
signal on_fortune

var explores = 0

var expands = 0
var enhances = 0
var structures = 0
var removals = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setup(deck, p_tooltip):
	player_deck = deck
	tooltip = p_tooltip

func create_explore(p_explores, turn_manager: TurnManager):
	for point in $Points.get_children():
		$Points.remove_child(point)
	explores = p_explores
	$CenterContainer/PanelContainer/VBox/HBox/Label.text = "Explorations Remaining: " + str(explores)
	var DIST = 250
	var positions = []
	positions.shuffle()
	# Add card
	create_point("Gain Card", Vector2(-DIST - 70, 0), func(pt):
		use_explore(pt)
		add_card("common", 5 - Mastery.BlockShop))
	
	if turn_manager.year == 4 or turn_manager.year == 7 or turn_manager.year == 10:
		create_point("Rare Card", Vector2(0, -DIST - 70), func(pt):
			use_explore(pt)
			add_card("rare", 5 - Mastery.BlockShop))
		create_point("Rare Structure", Vector2(0, DIST + 70), func(pt):
			use_explore(pt)
			add_structure("rare"))
	
	# Event
	create_point("Event", Vector2(-DIST, -DIST), func(pt):
		use_explore(pt)
		on_event.emit())
		
	# Enhance
	if enhances <= turn_manager.year / 2 and $Points.get_child_count() < 5:
		create_point("Enhance Card", Vector2(DIST + 70, 0), func(pt):
			use_explore(pt)
			enhances += 1
			select_enhance("common"))
	
	# Remove card
	if removals <= turn_manager.year / 3 and $Points.get_child_count() < 5:
		create_point("Remove Card", Vector2(DIST, -DIST), func(pt):
			select_card_to_remove(pt))
	
	# Structure
	if structures <= turn_manager.year / 3 and $Points.get_child_count() < 5:
		create_point("Structure", Vector2(DIST, DIST), func(pt):
			use_explore(pt)
			structures += 1
			add_structure("common"))
		
	# Expand
	if expands <= turn_manager.year / 3 and $Points.get_child_count() < 5:
		create_point("Expand Farm", Vector2(-DIST, DIST), func(pt):
			use_explore(pt)
			expands += 1
			expand_farm())

func use_explore(node):
	if node != null:
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
		visible = false
		callback.call(point))
	$Points.add_child(point)

func add_card(rarity: String, count: int):
	var cards;
	if Global.FARM_TYPE == "WILDERNESS":
		cards = cards_database.get_random_action_cards(rarity, count)
	else:
		cards = cards_database.get_random_cards(rarity, count)
	pick_card_from(cards)

func pick_card_from(cards):
	var pick_option_ui = PickOption.instantiate()
	add_sibling(pick_option_ui)
	var prompt = "Pick a card to add to your deck"

	pick_option_ui.setup(prompt, cards, func(selected):
		player_deck.append(selected.card_info)
		remove_sibling(pick_option_ui)
		visible = true, func():
			remove_sibling(pick_option_ui)
			visible = true)

func select_card_to_remove(pt):
	var select_card = SelectCard.instantiate()
	select_card.tooltip = tooltip
	select_card.size = Constants.VIEWPORT_SIZE
	select_card.z_index = 2
	select_card.theme = load("res://assets/theme_large.tres")
	select_card.select_callback = func(card_data):
		remove_sibling(select_card)
		player_deck.erase(card_data)
		visible = true
		use_explore(pt)
		removals += 1
	select_card.select_cancelled.connect(func():
		remove_sibling(select_card)
		visible = true)
	add_sibling(select_card)
	select_card.do_card_pick(player_deck, "Select a card to remove")

func select_enhance(rarity: String):
	var enhances
	if Global.FARM_TYPE == "WILDERNESS":
		enhances = cards_database.get_random_enhance_noseed(rarity, 3)
	else:
		enhances = cards_database.get_random_enhance(rarity, 3, false)
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
	
func add_structure(rarity: String):
	var structures = cards_database.get_random_structures(3, rarity)
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

func pick_fortune(prompt: String, options: Array[Fortune]):
	if options.size() == 0:
		options = cards_database.get_all_blessings()
		options.shuffle()
		options = options.slice(0, 3)
	var pick_option_ui = PickOption.instantiate()
	add_sibling(pick_option_ui)
	var on_pick = func(selected):
		remove_sibling(pick_option_ui)
		on_fortune.emit(selected)
	pick_option_ui.setup(prompt, options, on_pick, null)

func remove_sibling(node):
	$'../'.remove_child(node)

func _on_close_pressed():
	visible = false

func expand_farm():
	$"../../".on_expand_farm()

func save_data():
	return {
		"expands": expands,
		"structures": structures,
		"removals": removals,
		"enhances": enhances
	}

func load_data(data):
	expands = data.expands
	structures = data.structures
	removals = data.removals
	enhances = data.enhances
