extends Node2D

var stock = []
var ShopItem = preload("res://scenes/shop_item.tscn")
var card_database = preload("res://scripts/cards_database.gd")

signal on_shop_closed
signal on_item_bought

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer.size = get_viewport_rect().size
	fill_shop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fill_shop():
	stock = [
		{
			"type": "card",
			"name": "Blueberry",
			"cost": 30
		},
		{
			"type": "card",
			"name": "Pumpkin",
			"cost": 10
		},
		{
			"type": "card",
			"name": "Carrot",
			"cost": 10
		},
		{
			"type": "card",
			"name": "Scythe",
			"cost": 20
		}
	]
	
	for item in stock:
		var new_node = ShopItem.instantiate()
		if item.type == "card":
			new_node.card_name = item.name
		new_node.card_cost = item.cost
		new_node.on_card_bought.connect(_on_shop_item_on_card_bought)
		$PanelContainer/ShopContainer/ShopContent/StockContainer.add_child(new_node)
	


func _on_shop_item_on_card_bought(card_name, card_cost) -> void:
	on_item_bought.emit(card_name)


func _on_close_button_pressed() -> void:
	on_shop_closed.emit()
