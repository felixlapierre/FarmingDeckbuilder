extends Node2D

var CardBase;
var PlayerHand;
const CardSize = Vector2(125, 175)
var CardSelected = []
var DeckSize

var CenterCardOval
var HorizontalRadius
var VerticalRadius
var Angle = deg_to_rad(90) - 0.25
var OvalAngleVector = Vector2()

func _ready() -> void:
	CardBase = preload("res://scenes/card_base.tscn")
	PlayerHand = preload("res://scripts/player_hand.gd")
	DeckSize = PlayerHand.CardList.size()
	CenterCardOval = get_viewport_rect().size * Vector2(0.5, 1.2)
	HorizontalRadius = get_viewport_rect().size.x * 0.45
	VerticalRadius = get_viewport_rect().size.y * 0.40
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func drawcard():
	var new_card = CardBase.instantiate()
	CardSelected = randi() % DeckSize
	new_card.Cardname = PlayerHand.CardList[CardSelected]

	# position the card in the hand
	OvalAngleVector = Vector2(HorizontalRadius * cos(Angle), -VerticalRadius * sin(Angle))
	new_card.position = CenterCardOval + OvalAngleVector - new_card.size / 2
	new_card.rotation = -Angle/4 + PI/8
	Angle += 0.25


	new_card.scale *= CardSize / new_card.size
	$Cards.add_child(new_card);
	PlayerHand.CardList.erase(PlayerHand.CardList[CardSelected])
	DeckSize = PlayerHand.CardList.size()
	return DeckSize
