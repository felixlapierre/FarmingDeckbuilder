extends Node2D
class_name Cards

var CardBase;
var PlayerHand;
const CardSize = Vector2(200, 280)
var CardSelected = []

var CenterCardOval
var HorizontalRadius
var VerticalRadius
var OvalAngleVector = Vector2()
var Angle = 0
var CardSpread = 0.25
var number_of_cards_in_hand = 0

var deck_cards: Array[CardData] = []
var discard_pile_cards: Array[CardData] = []

@onready var tooltip = $Tooltip
@onready var HAND_CARDS = $Hand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CardBase = preload("res://src/cards/card_base.tscn")

	CenterCardOval = Vector2(Constants.VIEWPORT_SIZE) * Vector2(0.5, 1.2)
	HorizontalRadius = Constants.VIEWPORT_SIZE.x * 0.45
	VerticalRadius = Constants.VIEWPORT_SIZE.y * 0.40

func do_winter_clear():
	for display_card in $Hand.get_children():
		$Hand.remove_child(display_card)
	for display_card in $Discarding.get_children():
		$Discarding.remove_child(display_card)
	discard_pile_cards = []
	deck_cards = []
	number_of_cards_in_hand = 0

func set_deck_for_year(new_deck):
	for card in new_deck:
		deck_cards.append(card.copy())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func draw_hand(count, week):
	var start_hand_count = number_of_cards_in_hand
	if week == 1:
		draw_springbound_cards(count)
	while number_of_cards_in_hand - start_hand_count < count and number_of_cards_in_hand < Global.MAX_HAND_SIZE:
		drawcard()
		if deck_cards.size() == 0 and discard_pile_cards.size() == 0:
			break
	reorganize_hand()

func draw_one_card():
	drawcard()
	reorganize_hand()
	
func drawcard():
	if $Hand.get_child_count() >= Global.MAX_HAND_SIZE:
		return
	# Refill the draw pile if necessary
	if deck_cards.size() == 0:
		for card in discard_pile_cards:
			deck_cards.append(card)
		discard_pile_cards.clear()
	
	# If deck is still empty then all cards are in hand and we can't draw
	if deck_cards.size() == 0:
		return
	
	CardSelected = randi() % deck_cards.size()
	draw_specific_card(deck_cards[CardSelected])

	# Remove card from deck
	deck_cards.erase(deck_cards[CardSelected])
	return deck_cards.size()

func draw_specific_card(card_data: CardData):
	draw_specific_card_from(card_data, $"../UserInterface/UI/Deck".position)

func draw_specific_card_from(card_data: CardData, from: Vector2):
	# Create the new card and initialize its starting values
	var new_card = CardBase.instantiate()

	new_card.tooltip = tooltip
	new_card.set_card_info(card_data)
	new_card.position = from - CardSize / 2
	new_card.target_position = new_card.position
	new_card.starting_position = new_card.position
	new_card.target_scale = new_card.resting_scale
	new_card.scale = new_card.resting_scale
	new_card.starting_rotation = 0
	new_card.state = Enums.CardState.MoveDrawnCardToHand
	
	# Add it to the hand and call reorganize_hand which will position it
	$Hand.add_child(new_card);
	number_of_cards_in_hand += 1

func draw_springbound_cards(count: int):
	var springbound_cards = []
	for card in deck_cards:
		if card.get_effect("springbound") != null:
			springbound_cards.append(card)
	springbound_cards.shuffle()
	while springbound_cards.size() > 0 and number_of_cards_in_hand < count:
		var card = springbound_cards.pop_front()
		draw_specific_card(card)
		deck_cards.erase(card)

func play_card():
	# Find the card in our hand
	var playedcard
	for card in $Hand.get_children():
		if card.state == Enums.CardState.InMouse:
			playedcard = card
	
	# Have to draw before discarding or we could draw the card we just discarded
	var draw = playedcard.card_info.get_effect("draw")
	if draw != null and draw.on == "play":
		for i in range(draw.strength):
			drawcard()
	
	# If Obliviate, delete instead of discarding
	if playedcard.card_info.get_effect("burn") != null\
		or playedcard.card_info.get_effect("fleeting") != null:
		remove_hand_card(playedcard)
	else:
		discard_card(playedcard)
	
	# Remove it from selected_card global var
	Global.selected_card = null
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
		if HandCard.state == Enums.CardState.InHand:
			HandCard.set_state(Enums.CardState.ReOrganiseHand, newPosition, newRotation, null)
		elif HandCard.state == Enums.CardState.MoveDrawnCardToHand:
			HandCard.set_state(Enums.CardState.MoveDrawnCardToHand, newPosition, newRotation, null)
			HandCard.move_using_tween(0.5)

func discard_hand():
	for card in $Hand.get_children():
		if card.card_info.get_effect("fleeting") != null:
			remove_hand_card(card)
		elif card.card_info.get_effect("frozen") == null:
			discard_card(card)
	reorganize_hand()

func obliviate_rightmost():
	var hand_count = $Hand.get_child_count()
	if hand_count > 0:
		var card = $Hand.get_child(hand_count - 1)
		remove_hand_card(card)

func discard_card(card):
	$Hand.remove_child(card)
	$Discarding.add_child(card)
	card.set_state(Enums.CardState.MoveToDiscard, Constants.VIEWPORT_SIZE, PI/4, card.resting_scale * 0.1)
	card.move_using_tween(0.5)
	number_of_cards_in_hand -= 1
	discard_pile_cards.append(card.card_info)

func finish_discard(card):
	$Discarding.remove_child(card)

func add_card_from_shop(card_info):
	discard_pile_cards.append(card_info)

func get_hand_info() -> Array[CardData]:
	var card_info_array: Array[CardData] = []
	for card in $Hand.get_children():
		card_info_array.append(card.card_info)
	return card_info_array

func remove_card_with_info(card_info):
	# Temporary, eventually shop will just pass around the entire deck
	var card
	for hand_card in $Hand.get_children():
		if Helper.card_info_matches(hand_card.card_info, card_info):
			card = hand_card
	if card != null:
		remove_hand_card(card)
	reorganize_hand()

func remove_hand_card(card):
	$Hand.remove_child(card)
	$Discarding.add_child(card)
	card.set_state(Enums.CardState.MoveToDiscard, null, null, card.resting_scale * 0.1)
	card.move_using_tween(0.5)
	number_of_cards_in_hand -= 1

func set_cards_visible(visible: bool):
	for child in $Hand.get_children():
		child.set_visible(visible)
	for child in $Discarding.get_children():
		child.set_visible(visible)

func make_random_card_free():
	for card in $Hand.get_children():
		var info: CardData = card.card_info
		if info.cost > 0:
			var copy = info.copy()
			copy.cost = 0
			card.set_card_info(copy)
			return

func get_deck_info() -> Array[CardData]:
	return deck_cards

func get_discard_info() -> Array[CardData]:
	return discard_pile_cards

func unselect_current_card():
	for card in $Hand.get_children():
		if card.state == Enums.CardState.InMouse:
			card.set_state(Enums.CardState.ReOrganiseHand, card.resting_position, card.resting_rotation, card.resting_scale)
			card.reset_starting_position()
