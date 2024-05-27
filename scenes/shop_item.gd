extends Control

signal on_card_bought

var CardBase = preload("res://scenes/card_base.tscn")
var card_database = preload("res://scripts/cards_database.gd")
var ITEM_SIZE = Vector2()
var card
var cost

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_card(new_card_name, card_cost):
	cost = card_cost
	$ItemContainer/BuyButton.text = "Buy (" + str(card_cost) + ")"
	card = CardBase.instantiate()
	card.state = CardState.InShop
	card.card_name = new_card_name
	$ItemContainer.add_child(card)
	$ItemContainer.move_child(card, 0)

func _on_buy_button_pressed() -> void:
	on_card_bought.emit(self, card.card_name, cost)
	
func move_card_to_discard():
	# Need to remove the card from the control node otherwise it will displace
	# other UI elements during the discard animation
	$ItemContainer.remove_child(card)
	$Discarding.add_child(card)
	# Card position is no longer being controlled and z-indexed so we have to set it manually
	card.position = $ItemContainer.global_position
	card.z_index = 2
	card.set_state(CardState.MoveToDiscard, get_viewport_rect().size, 0, Vector2(0, 0))

func finish_discard(card):
	$Discarding.remove_child(card)
