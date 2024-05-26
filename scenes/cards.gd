extends Node2D

var CardBase;
var PlayerHand;
const CardSize = Vector2(125, 175)
var CardSelected = []

var CenterCardOval
var HorizontalRadius
var VerticalRadius
var OvalAngleVector = Vector2()
var Angle = 0
var CardSpread = 0.25
var number_of_cards_in_hand = 0

var starting_deck = ["Blueberry", "Carrot", "Carrot", "Pumpkin", "Carrot", "Blueberry", "Scythe", "Scythe"]
var card_database
var deck_cards = []
var discard_pile_cards = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CardBase = preload("res://scenes/card_base.tscn")
	card_database = preload("res://scripts/cards_database.gd")
	CenterCardOval = Vector2(get_viewport().size) * Vector2(0.5, 1.2)
	HorizontalRadius = get_viewport_rect().size.x * 0.45
	VerticalRadius = get_viewport_rect().size.y * 0.40
	for cardname in starting_deck:
		deck_cards.append(card_database.DATA.get(cardname))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func draw_hand():
	for i in range(Constants.BASE_HAND_SIZE):
		drawcard()
	
func drawcard():
	# Refill the draw pile if necessary
	if deck_cards.size() == 0:
		print("Refill draw pile from discard of size " + str(discard_pile_cards.size()))
		for card in discard_pile_cards:
			deck_cards.append(card)
		discard_pile_cards.clear()
		
	# Create the new card and initialize its starting values
	var new_card = CardBase.instantiate()
	CardSelected = randi() % deck_cards.size()
	new_card.card_name = deck_cards[CardSelected].name
	new_card.position = $"../Deck".position - CardSize / 2
	new_card.starting_position = new_card.position
	new_card.target_scale = new_card.resting_scale
	new_card.scale = new_card.resting_scale
	new_card.starting_rotation = 0
	new_card.state = CardState.MoveDrawnCardToHand
	
	# Add it to the hand and call reorganize_hand which will position it
	$Hand.add_child(new_card);
	number_of_cards_in_hand += 1
	reorganize_hand()

	# Remove card from deck
	deck_cards.erase(deck_cards[CardSelected])
	return deck_cards.size()

func play_card():
	# Delete the card
	var playedcard
	for card in $Hand.get_children():
		if card.state == CardState.InMouse:
			playedcard = card
	discard_card(playedcard)
	
	# Remove it from selected_card global var
	Global.selected_card = Global.NO_CARD
	# Rearrange the rest of the hand cards
	reorganize_hand()
	
func reorganize_hand():
	var card_number = 0
	for HandCard in $Hand.get_children():
		# Calculate the card's new rotation and position using oval math I don't really understand
		Angle = PI/2 + CardSpread*(float(number_of_cards_in_hand-1)/2 - card_number)
		OvalAngleVector = Vector2(HorizontalRadius * cos(Angle), -VerticalRadius * sin(Angle))
		var newPosition = CenterCardOval + OvalAngleVector - HandCard.size * 0.4
		var newRotation = -Angle/4 + PI/8
		HandCard.set_new_resting_position(newPosition, newRotation)
		
		# Set card number and change its state
		HandCard.card_number_in_hand = card_number
		card_number += 1
		if HandCard.state == CardState.InHand:
			HandCard.set_state(CardState.ReOrganiseHand, newPosition, newRotation, null)
		elif HandCard.state == CardState.MoveDrawnCardToHand:
			HandCard.set_state(CardState.MoveDrawnCardToHand, newPosition, newRotation, null)
			HandCard.move_using_tween(0.5)

func discard_hand():
	for card in $Hand.get_children():
		discard_card(card)

func discard_card(card):
	$Hand.remove_child(card)
	$Discarding.add_child(card)
	card.set_state(CardState.MoveToDiscard, get_viewport_rect().size, PI/4, card.resting_scale * 0.1)
	card.move_using_tween(0.5)
	number_of_cards_in_hand -= 1
	discard_pile_cards.append(card_database.DATA.get(card.card_name))

func finish_discard(card):
	$Discarding.remove_child(card)
