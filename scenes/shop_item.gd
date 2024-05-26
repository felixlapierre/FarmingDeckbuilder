extends Control

@export var card_name: String = "Blueberry"
@export var card_cost: int = 15

signal on_card_bought

var CardBase = preload("res://scenes/card_base.tscn")
var card_database = preload("res://scripts/cards_database.gd")
var ITEM_SIZE = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if card_name != null:
		$ItemContainer/Header/TypeLabel.text = "Type: Card"
		$ItemContainer/Header/CostLabel.text = "Cost: " + str(card_cost)
		var display_card = CardBase.instantiate()
		var card = card_database.DATA[card_name]
		display_card.state = CardState.InShop
		$ItemContainer.add_child(display_card)
		$ItemContainer.move_child(display_card, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_buy_button_button_up() -> void:
	on_card_bought.emit(card_name, card_cost)
