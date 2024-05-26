extends Node2D

var stock = []
var ShopItem = preload("res://scenes/shop_item.tscn")
var card_database = preload("res://scripts/cards_database.gd")

signal on_shop_closed
signal on_item_bought

var reset_shop_cost = 10
var remove_card_cost = 50
var shop_item_capacity = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer.size = get_viewport_rect().size
	fill_shop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fill_shop():
	# Clear existing shop
	for child in $PanelContainer/ShopContainer/ShopContent/StockContainer.get_children():
		$PanelContainer/ShopContainer/ShopContent/StockContainer.remove_child(child)
	
	# Generate stock (dict)
	var stock = generate_random_shop_items(shop_item_capacity)
	for key in stock.keys():
		var value = stock[key]
		var new_node = ShopItem.instantiate()
		if value.type == "CARD":
			new_node.card_name = key
		new_node.card_cost = randi_range(value.min_cost, value.max_cost)
		new_node.on_card_bought.connect(_on_shop_item_on_card_bought)
		$PanelContainer/ShopContainer/ShopContent/StockContainer.add_child(new_node)
	
func generate_random_shop_items(count):
	var options = card_database.SHOP
	var total_weight = 0.0
	var result = {}
	for key in options.keys():
		total_weight += float(options[key].weight)
	var i = 0
	while i < count:
		var selected = randf_range(0, total_weight)
		for key in options.keys():
			selected -= float(options[key].weight)
			if selected <= 0:
				if !result.has(key):
					result[key] = options[key]
					i += 1
				break
	return result

func _on_shop_item_on_card_bought(card_name, card_cost) -> void:
	on_item_bought.emit(card_name)


func _on_close_button_pressed() -> void:
	on_shop_closed.emit()
