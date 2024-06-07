extends Node2D

var stock = []
var ShopItem = preload("res://scenes/shop_item.tscn")
var card_database = preload("res://scripts/cards_database.gd")
var CardBase = preload("res://scenes/card_base.tscn")
var ShopCard = preload("res://scenes/shop_card.tscn")
var ShopButton = preload("res://scenes/shop_button.tscn")
var ShopDisplay = preload("res://scenes/shop_display.tscn")

signal on_shop_closed
signal on_item_bought
signal on_money_spent
signal on_card_removed
signal on_structure_place

@export var player_money: int

var shop_item_capacity = 4

var player_cards

@onready var CHOICE_ONE = $PanelContainer/ShopContainer/ChoiceOne
@onready var STOCK_ONE = $PanelContainer/ShopContainer/ChoiceOne/Stock
@onready var CHOICE_TWO = $PanelContainer/ShopContainer/ChoiceTwo
@onready var STOCK_TWO = $PanelContainer/ShopContainer/ChoiceTwo/Stock

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RemoveCardContainer.size = Constants.VIEWPORT_SIZE
	player_money = 500
	update_labels()
	fill_shop()

func set_deck(deck):
	player_cards = deck

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fill_shop():
	set_row_visible(1, true)
	set_row_visible(2, true)
	clear_row(1)
	clear_row(2)
	fill_row_one()
	fill_row_two()
	$PanelContainer.position = Constants.VIEWPORT_SIZE / 2 - $PanelContainer.size / 2

func clear_row(row):
	var node
	match row:
		1:
			node = STOCK_ONE
		2:
			node = STOCK_TWO
	for child in node.get_children():
		node.remove_child(child)

func fill_row_number(row):
	match row:
		1:
			fill_row_one()
		2:
			fill_row_two()

func fill_row_one():
	var options = card_database.get_all_cards()
	var selected = []
	for option in options:
		if option.type == "SEED" or option.type == "ACTION":
			selected.append(option)
	var stock = generate_random_shop_items(shop_item_capacity, selected)
	fill_row(STOCK_ONE, 1, stock)
	STOCK_ONE.add_child(create_scrap_option(1, 1))

func fill_row_two():
	var structures = card_database.get_all_structure()
	var selected = []
	for structure in structures:
		selected.append(structure)
	var enhances = card_database.get_all_enhance()
	for enhance in enhances:
		selected.append(enhance)
	var stock = generate_random_shop_items(3, selected)
	fill_row(STOCK_TWO, 2, stock)
	STOCK_TWO.add_child(create_remove_card_option())
	STOCK_TWO.add_child(create_scrap_option(2, 2))

func fill_row(node, row_number, stock):
	for item in stock:
		if item.CLASS_NAME == "CardData":
			var new_node = ShopCard.instantiate()
			new_node.card_data = item
			new_node.on_clicked.connect(func(option): on_buy(option, row_number))
			node.add_child(new_node)
		elif item.CLASS_NAME == "Structure":
			var new_node = ShopDisplay.instantiate()
			new_node.set_data(item)
			new_node.callback = func(): on_buy_structure(item, row_number)
			node.add_child(new_node)
		elif item.CLASS_NAME == "Enhance":
			var new_node = ShopDisplay.instantiate()
			new_node.set_data(item)
			new_node.callback = func(): on_enhance_selected(item, row_number)
			node.add_child(new_node)

func create_scrap_option(amount, row):
	var scrap = ShopButton.instantiate()
	scrap.text = "Gain"
	scrap.cost = amount
	scrap.row = row
	scrap.option_selected.connect(on_scrap)
	return scrap

func create_remove_card_option():
	var remove = ShopButton.instantiate()
	remove.text = "Remove Card"
	remove.cost = 0
	remove.row = 2
	remove.option_selected.connect(_on_remove_card_button_pressed)
	return remove

# returns an array, items can be either CardData or Enhance
func generate_random_shop_items(count, options):
	var common = []
	var rare = []
	for option in options:
		if option.rarity == "common":
			common.append(option)
		elif option.rarity == "rare":
			rare.append(option)

	var result = []
	var i = 0
	while i < count:
		var selection = common if randf() > 0.30 else rare
		var selected = randi_range(0, selection.size() - 1)
		#if !result.has(selected):
		result.append(selection[selected])
		i += 1
	return result

func on_buy_row1(option):
	on_buy(option, 1)

func on_buy_row2(option):
	on_buy(option, 2)

func on_buy(option, row):
	if option.card_info.type == "STRUCTURE":
		on_structure_place.emit(option.card_info, func(): finish_item_bought(option, option.card_info, row))
		return
	finish_item_bought(option, option.card_info, row)

func finish_item_bought(card, card_data, row) -> void:
	if card_data.type != "STRUCTURE":
		on_item_bought.emit(card_data)
	set_row_visible(row, false)
	update_labels()

func set_row_visible(row, vis):
	match row:
		1:
			for child in CHOICE_ONE.get_children():
				child.visible = vis
		2:
			for child in CHOICE_TWO.get_children():
				child.visible = vis

func _on_close_button_pressed() -> void:
	on_shop_closed.emit()

func _on_remove_card_button_pressed(cost, row) -> void:
	$RemoveCardContainer.visible = true
	$RemoveCardContainer/SelectCard.select_callback = func(card_data):
		on_card_removed.emit(card_data)
		set_row_visible(row, false)
		update_labels()
		$RemoveCardContainer.visible = false
	$RemoveCardContainer/SelectCard.do_card_pick(player_cards, "Select a card to remove")
	
func _on_card_remove_cancelled() -> void:
	$RemoveCardContainer.visible = false

func on_week_pass():
	fill_shop()
	update_labels()

func update_labels():
	$PanelContainer/ShopContainer/Header/MoneyLabel.text = "$$$: " + str(player_money)

func on_reroll(cost, row):
	if player_money + cost < 0:
		return
	player_money += cost
	update_labels()
	clear_row(row)
	fill_row_number(row)

func on_scrap(amount, row):
	player_money += amount
	set_row_visible(row, false)
	update_labels()

func on_enhance_selected(enhance: Enhance, row):
	$RemoveCardContainer.visible = true
	$RemoveCardContainer/SelectCard.select_callback = func(card_data: CardData):
		var enhanced = card_data.apply_enhance(enhance)
		on_card_removed.emit(card_data)
		on_item_bought.emit(enhanced)
		set_row_visible(row, false)
		update_labels()
		$RemoveCardContainer.visible = false
	$RemoveCardContainer/SelectCard.do_enhance_pick(player_cards, enhance, "Select a card to enhance")

func on_buy_structure(structure, row):
	on_structure_place.emit(structure, func(): 	
		set_row_visible(row, false)
		update_labels())
