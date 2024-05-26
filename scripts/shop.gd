extends Node2D

var stock = []
var ShopItem = preload("res://scenes/shop_item.tscn")
var card_database = preload("res://scripts/cards_database.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
		}
	]
	
	for item in stock:
		var new_node = ShopItem.instantiate()
		if item.type == "card":
			new_node.card_name = item.name
		$ShopContainer/ShopContent/StockContainer.add_child(new_node)
	


func _on_shop_item_on_card_bought(card_name, card_cost) -> void:
	
