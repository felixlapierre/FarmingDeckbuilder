extends Node2D

var CardBase;
var PlayerHand;
const CardSize = Vector2(125, 175)
var CardSelected = []
var DeckSize
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CardBase = preload("res://scenes/card_base.tscn")
	PlayerHand = preload("res://scripts/player_hand.gd")
	DeckSize = PlayerHand.CardList.size()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func drawcard():
	var new_card = CardBase.instantiate()
	CardSelected = randi() % DeckSize
	new_card.Cardname = PlayerHand.CardList[CardSelected]
	new_card.position = get_global_mouse_position()
	new_card.scale *= CardSize / new_card.size
	$Cards.add_child(new_card);
	PlayerHand.CardList.erase(PlayerHand.CardList[CardSelected])
	DeckSize = PlayerHand.CardList.size()
	return DeckSize
