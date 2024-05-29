extends Control

signal on_purchase

var CardBase = preload("res://scenes/card_base.tscn")
var card_database = preload("res://scripts/cards_database.gd")
var ITEM_SIZE = Vector2()
# Format:
# type: CARD or STRUCTURE
# data: Data of the card or structure from the database
# cost: Cost of the item in yield
# name: Name of the item from the database
var item
var card
var cost

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_item(new_item):
	item = new_item
	card = CardBase.instantiate()
	card.state = CardState.InShop
	card.set_card_info(item.data)
	$ItemContainer.add_child(card)
	$ItemContainer.move_child(card, 0)
	$ItemContainer/ItemPanel.visible = false
	cost = item.cost
	$ItemContainer/BuyButton.text = "Buy (" + str(cost) + ")"


func _on_buy_button_pressed() -> void:
	on_purchase.emit(self, item)
	
func move_card_to_discard():
	# Need to remove the card from the control node otherwise it will displace
	# other UI elements during the discard animation
	if item.type == "SEED" or item.type == "ACTION":
		$ItemContainer.remove_child(card)
		$Discarding.add_child(card)
		# Card position is no longer being controlled and z-indexed so we have to set it manually
		card.position = $ItemContainer.global_position
		card.z_index = 2
		card.set_state(CardState.MoveToDiscard, Constants.VIEWPORT_SIZE.size, 0, Vector2(0, 0))
	elif item.type == "STRUCTURE":
		$ItemContainer.remove_child(card)

func finish_discard(card):
	$Discarding.remove_child(card)
