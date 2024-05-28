extends Node2D

var stock = []
var ShopItem = preload("res://scenes/shop_item.tscn")
var card_database = preload("res://scripts/cards_database.gd")

signal on_shop_closed
signal on_item_bought
signal on_money_spent
signal on_card_removed
signal on_structure_place

@export var player_money: int

var reset_shop_base_cost = 15
var reset_shop_cost = 15
var reset_shop_increment = 15
var remove_card_base_cost = 50
var remove_card_cost = 50
var remove_card_cost_increment = 50

var shop_item_capacity = 6

var player_cards

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer.size = get_viewport_rect().size
	$RemoveCardContainer.size = get_viewport_rect().size
	update_labels()
	fill_shop()

func set_deck(deck):
	player_cards = deck

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fill_shop():
	# Clear existing shop
	for child in $PanelContainer/ShopContainer/ShopContent/StockContainer.get_children():
		$PanelContainer/ShopContainer/ShopContent/StockContainer.remove_child(child)
	
	# Generate stock (dict)
	var stock = generate_random_shop_items(shop_item_capacity)
	for item in stock:
		var new_node = ShopItem.instantiate()
		var cost = randi_range(10, 50) if item.rarity == "common" else randi_range(50, 100)
		new_node.set_item({"name": item.name, "data": item, "cost": cost, "type": item.type})
		new_node.on_purchase.connect(_on_shop_item_on_card_bought)
		$PanelContainer/ShopContainer/ShopContent/StockContainer.add_child(new_node)
	
func generate_random_shop_items(count):
	var options = card_database.DATA
	var common = []
	var rare = []
	for key in options.keys():
		var value = options[key]
		if value.rarity == "common":
			common.append(value)
		elif value.rarity == "rare":
			rare.append(value)

	var result = []
	var i = 0
	while i < count:
		var selection = common if randf() > 0.70 else rare
		var selected = randi_range(0, selection.size() - 1)
		result.append(selection[selected])
		i += 1
	return result

func _on_shop_item_on_card_bought(ui_shop_item, item) -> void:
	if item.cost > player_money:
		return
	if item.type == "STRUCTURE":
		on_structure_place.emit(item, func(): finish_item_bought(ui_shop_item, item))
		return
	finish_item_bought(ui_shop_item, item)

func finish_item_bought(ui_shop_item, item) -> void:
	on_item_bought.emit(item)
	ui_shop_item.move_card_to_discard()
	var items = generate_random_shop_items(1)
	var new_item = items[0]
	var cost = randi_range(10, 50) if new_item.rarity == "common" else randi_range(50, 100)
	ui_shop_item.set_item({"name": new_item.name, "data": new_item, "cost": cost, "type": new_item.type})
	update_labels()

func _on_close_button_pressed() -> void:
	on_shop_closed.emit()


func _on_reset_shop_button_pressed() -> void:
	if player_money > reset_shop_cost:
		on_money_spent.emit(reset_shop_cost)
		reset_shop_cost += reset_shop_increment
		update_labels()
		fill_shop()


func _on_remove_card_button_pressed() -> void:
	if player_money > remove_card_cost:
		# TODO: Pick card to remove and potentially cancel
		$RemoveCardContainer.visible = true
		$RemoveCardContainer/SelectCard.do_card_pick(player_cards, "Select a card to remove")

func _on_card_remove_chosen(card) -> void:
	on_card_removed.emit(card.card_info)
	on_money_spent.emit(remove_card_cost)
	remove_card_cost += remove_card_cost_increment
	update_labels()
	$RemoveCardContainer.visible = false
	
func _on_card_remove_cancelled() -> void:
	$RemoveCardContainer.visible = false

func on_week_pass():
	fill_shop()
	reset_shop_cost = reset_shop_base_cost
	remove_card_cost = remove_card_base_cost
	update_labels()

func update_labels():
	$PanelContainer/ShopContainer/ShopContent/SideActions/ResetShopContainer/ResetShopButton.text = "Reset Shop ("+str(reset_shop_cost)+")"
	$PanelContainer/ShopContainer/ShopContent/SideActions/RemoveCardContainer/RemoveCardButton.text = "Remove Card ("+str(remove_card_cost)+")"
	$PanelContainer/ShopContainer/Header/MoneyLabel.text = "$$$: " + str(player_money)
