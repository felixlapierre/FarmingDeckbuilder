extends Node2D

var CardBase;
var PlayerHand;
const CardSize = Vector2(125, 175)
var CardSelected = []
var DeckSize

var CenterCardOval
var HorizontalRadius
var VerticalRadius
var OvalAngleVector = Vector2()
var Angle = 0
var CardSpread = 0.25
var number_of_cards_in_hand = 0
var Card_Number = 0

#Imported from CardBase
enum {
	InHand,
	InPlay,
	InMouse,
	FocusInHand,
	MoveDrawnCardToHand,
	ReOrganiseHand
}

func _ready() -> void:
	CardBase = preload("res://scenes/card_base.tscn")
	PlayerHand = preload("res://scripts/player_hand.gd")
	DeckSize = PlayerHand.CardList.size()
	CenterCardOval = Vector2(get_viewport().size) * Vector2(0.5, 1.2)
	HorizontalRadius = get_viewport_rect().size.x * 0.45
	VerticalRadius = get_viewport_rect().size.y * 0.40
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func drawcard():
	Angle = PI/2 + CardSpread*(float(number_of_cards_in_hand)/2 - number_of_cards_in_hand)
	var new_card = CardBase.instantiate()
	CardSelected = randi() % DeckSize
	new_card.card_name = PlayerHand.CardList[CardSelected]

	# position the card in the hand
	OvalAngleVector = Vector2(HorizontalRadius * cos(Angle), -VerticalRadius * sin(Angle))
	new_card.position = $Deck.position - CardSize / 2
	new_card.starting_position = new_card.position
	new_card.target_position = CenterCardOval + OvalAngleVector - new_card.size / 2
	new_card.resting_position = new_card.target_position
	new_card.target_scale = new_card.resting_scale
	new_card.scale = new_card.resting_scale
	new_card.starting_rotation = 0
	new_card.target_rotation = -Angle/4 + PI/8
	new_card.resting_rotation = new_card.target_rotation
	new_card.reset_starting_position()

	new_card.state = MoveDrawnCardToHand
	Card_Number = 0
	new_card.card_number_in_hand = number_of_cards_in_hand
	for HandCard in $Cards.get_children(): #reorganize hand
		Angle = PI/2 + CardSpread*(float(number_of_cards_in_hand)/2 - Card_Number)
		OvalAngleVector = Vector2(HorizontalRadius * cos(Angle), -VerticalRadius * sin(Angle))

		var newPosition = CenterCardOval + OvalAngleVector - HandCard.size / 2
		var newRotation = -Angle/4 + PI/8
		HandCard.set_new_resting_position(newPosition, newRotation)
		HandCard.card_number_in_hand = Card_Number
		Card_Number += 1
		if HandCard.state == InHand:
			HandCard.set_state(ReOrganiseHand, newPosition, newRotation, null)
		elif HandCard.state == MoveDrawnCardToHand:
			HandCard.set_state(MoveDrawnCardToHand, newPosition, newRotation, null)
			HandCard.move_using_tween(0.5)
	
	$Cards.add_child(new_card);
	new_card.move_using_tween(0.5)
	PlayerHand.CardList.erase(PlayerHand.CardList[CardSelected])
	DeckSize = PlayerHand.CardList.size()
	number_of_cards_in_hand += 1
	Card_Number += 1
	return DeckSize
