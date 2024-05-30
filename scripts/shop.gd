extends Node2D

var stock = []
var ShopItem = preload("res://scenes/shop_item.tscn")
var card_database = preload("res://scripts/cards_database.gd")
var CardBase = preload("res://scenes/card_base.tscn")
var ShopCard = preload("res://scenes/shop_card.tscn")
var ShopButton = preload("res://scenes/shop_button.tscn")

signal on_shop_closed
signal on_item_bought
signal on_money_spent
signal on_card_removed
signal on_structure_place

@export var player_money: int

var shop_item_capacity = 4

var player_cards

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer.size = Constants.VIEWPORT_SIZE
	$RemoveCardContainer.size = Constants.VIEWPORT_SIZE
	player_money = 5
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

func clear_row(row):
	var node
	match row:
		1:
			node = $PanelContainer/ShopContainer/ChoiceOne/Stock
		2:
			node = $PanelContainer/ShopContainer/ChoiceTwo/Stock
	for child in node.get_children():
		node.remove_child(child)

func fill_row_number(row):
	match row:
		1:
			fill_row_one()
		2:
			fill_row_two()

func fill_row_one():
	var stock = generate_random_shop_items_choice1(shop_item_capacity, ["SEED", "ACTION"])
	fill_row($PanelContainer/ShopContainer/ChoiceOne/Stock, 1, stock)

func fill_row_two():
	var stock = generate_random_shop_items_choice1(3, ["STRUCTURE", "UPGRADE"])
	fill_row($PanelContainer/ShopContainer/ChoiceTwo/Stock, 2, stock)
	$PanelContainer/ShopContainer/ChoiceTwo/Stock.add_child(create_remove_card_option())

func fill_row(node, row_number, stock):
	for item in stock:
		var new_node = ShopCard.instantiate()
		new_node.card_data = item
		new_node.on_clicked.connect(func(option): on_buy(option, row_number))
		node.add_child(new_node)
	node.add_child(create_scrap_option(row_number, row_number))

func create_scrap_option(amount, row):
	var scrap = ShopButton.instantiate()
	scrap.text = "Gain"
	scrap.cost = amount
	scrap.option_selected.connect(on_scrap)
	return scrap

func create_remove_card_option():
	var remove = ShopButton.instantiate()
	remove.text = "Remove Card"
	remove.cost = 0
	remove.option_selected.connect(_on_remove_card_button_pressed)
	return remove

func generate_random_shop_items_choice1(count, types):
	var options = card_database.get_all_cards()
	var common = []
	var rare = []
	for card in options:
		if types.has(card.type):
			if card.rarity == "common":
				common.append(card)
			elif card.rarity == "rare":
				rare.append(card)

	var result = []
	var i = 0
	while i < count:
		var selection = common if randf() > 0.70 else rare
		var selected = randi_range(0, selection.size() - 1)
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
	on_item_bought.emit(card_data)
	set_row_visible(row, false)
	update_labels()

func set_row_visible(row, vis):
	match row:
		1:
			for child in $PanelContainer/ShopContainer/ChoiceOne.get_children():
				child.visible = vis
		2:
			for child in $PanelContainer/ShopContainer/ChoiceTwo.get_children():
				child.visible = vis

func _on_close_button_pressed() -> void:
	on_shop_closed.emit()

func _on_remove_card_button_pressed(cost, row) -> void:
	$RemoveCardContainer.visible = true
	$RemoveCardContainer/SelectCard.do_card_pick(player_cards, "Select a card to remove")

func _on_card_remove_chosen(card) -> void:
	on_card_removed.emit(card.card_info)
	set_row_visible(2, false)
	update_labels()
	$RemoveCardContainer.visible = false
	
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
	print(str(amount) + " " + str(row))
