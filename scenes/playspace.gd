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
var NumberCardsHand = 0
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
	Angle = PI/2 + CardSpread*(float(NumberCardsHand)/2 - NumberCardsHand)
	var new_card = CardBase.instantiate()
	CardSelected = randi() % DeckSize
	new_card.Cardname = PlayerHand.CardList[CardSelected]

	# position the card in the hand
	OvalAngleVector = Vector2(HorizontalRadius * cos(Angle), -VerticalRadius * sin(Angle))
	new_card.startpos = $Deck.position - CardSize / 2
	new_card.targetpos = CenterCardOval + OvalAngleVector - new_card.size / 2
	new_card.startrot = 0
	new_card.targetrot = -Angle/4 + PI/8

	new_card.state = MoveDrawnCardToHand
	new_card.scale *= CardSize / new_card.size
	Card_Number = 0
	for HandCard in $Cards.get_children(): #reorganize hand
		Angle = PI/2 + CardSpread*(float(NumberCardsHand)/2 - Card_Number)
		OvalAngleVector = Vector2(HorizontalRadius * cos(Angle), -VerticalRadius * sin(Angle))

		HandCard.targetpos = CenterCardOval + OvalAngleVector - HandCard.size / 2
		HandCard.startrot = HandCard.rotation
		HandCard.targetrot = -Angle/4 + PI/8

		Card_Number += 1
		if HandCard.state == InHand:
			HandCard.state = ReOrganiseHand
			HandCard.startpos = HandCard.position
		elif HandCard.state == MoveDrawnCardToHand:
			HandCard.startpos = HandCard.targetpos - ((HandCard.targetpos - HandCard.position)/(1-HandCard.t))
	
	$Cards.add_child(new_card);
	PlayerHand.CardList.erase(PlayerHand.CardList[CardSelected])
	DeckSize = PlayerHand.CardList.size()
	NumberCardsHand += 1
	Card_Number += 1
	return DeckSize
