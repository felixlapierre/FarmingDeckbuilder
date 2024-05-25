extends MarginContainer

var card_name = "Blueberry"
var card_info;
var card_image = "res://assets/1616tinygarden/objects.png"
var card_database
var card_size = Vector2(125, 175)

var starting_position # For animating movement, start position of the card
var target_position # For animating movement, position card should end up at
var resting_position: Vector2 # Card comes back to rest at this position when we need to unfocus etc

var starting_scale: Vector2 # For animating scale, start scale
var resting_scale = card_size / size
var target_scale;

var starting_rotation = 0
var target_rotation = 0
var resting_rotation = 0

var ZoomInSize = 2
var t = 0

var tween

var number_of_cards_in_hand = 0
var card_number_in_hand = 0;
var neighbor_card;

var DRAWTIME = 0.5
var ZOOMTIME = 0.3
var HAND_TOP_Y

enum {
	InHand,
	InPlay,
	InMouse,
	FocusInHand,
	MoveDrawnCardToHand,
	ReOrganiseHand
}
var state = InHand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_database = preload("res://scripts/cards_database.gd")
	card_info = card_database.DATA[card_database.get(card_name)]
	
	var card_size = size
	HAND_TOP_Y = get_viewport_rect().size.y - card_size.y
	$CardBorder.scale *= card_size / $CardBorder.texture.get_size()
	$CardIcon.texture = load(card_image)
	$CardIcon.region_enabled = true
	$CardIcon.set_region_rect(Rect2(card_info.texture * 16, 0, 16, 16))
	$CardIcon.position = $CardBorder.texture.get_size() / 2
	$CardIcon.position.y /= 2
	$Focus.scale *= card_size / $Focus.size
	
	$HBoxContainer/VBoxContainer/BottomBar/TypeLabel.text = card_info.type
	$HBoxContainer/VBoxContainer/TopBar/CardNameLabel.text = card_info.name
	$HBoxContainer/VBoxContainer/TopBar/CardCostLabel.text = str(card_info.cost)
	$HBoxContainer/VBoxContainer/BottomBar/YieldLabel.text = str(card_info.yield) + " Yld / "
	$HBoxContainer/VBoxContainer/BottomBar/TimeLabel.text = str(card_info.time) + " Wks"
	$HBoxContainer/VBoxContainer/DescriptionLabel.text = card_info.text
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		InHand:
			pass
		InPlay:
			pass
		InMouse:
			var mouse_position = get_global_mouse_position() - card_size
			if mouse_position.y < HAND_TOP_Y:
				target_position = get_viewport_rect().size / Vector2(16, 4)
				scale = resting_scale * 1.7
				target_scale = scale
			else:
				target_position = mouse_position
				scale = resting_scale
				target_scale = scale
			process_move_linear(delta, 0.1)
		FocusInHand:
			process_move_linear(delta, ZOOMTIME/2)
		MoveDrawnCardToHand:
			if t > 1:
				state = InHand
			process_move_linear(delta, DRAWTIME)
		ReOrganiseHand:
			if t > 1:
				state = InHand
			process_move_linear(delta, 0.3)

func reset_starting_position():
	starting_position = position
	starting_rotation = rotation
	starting_scale = scale
	t = 0
	
func Reset_Card(card_number_in_hand):
	neighbor_card = $'../'.get_child(card_number_in_hand)
	neighbor_card = $'../'.get_child(card_number_in_hand)
	# Allows mousing directly from one card to another
	if neighbor_card.state != FocusInHand:
		neighbor_card.state = ReOrganiseHand
		neighbor_card.target_position = neighbor_card.resting_position
		neighbor_card.reset_starting_position()

func _on_focus_mouse_entered() -> void:
	match state:
		InHand, ReOrganiseHand:
			var new_position = resting_position
			new_position.y = get_viewport_rect().size.y - card_size.y*ZoomInSize
			set_state(FocusInHand, new_position, 0, resting_scale * 2)
			move_neighbors()
			Global.selected_card = Global.NO_CARD


func _on_focus_mouse_exited() -> void:
	match state:
		FocusInHand:
			set_state(ReOrganiseHand, resting_position, resting_rotation, resting_scale)
			reset_neighbors()

func move_neighbors():
	number_of_cards_in_hand = $'../../'.number_of_cards_in_hand - 1
	if card_number_in_hand - 1 >= 0:
		move_neighbor_card(card_number_in_hand - 1, true, 1) #true is left
	if card_number_in_hand - 2 >= 0:
		move_neighbor_card(card_number_in_hand - 2, true, 0.25) #true is left
	if card_number_in_hand + 1 <= number_of_cards_in_hand:
		move_neighbor_card(card_number_in_hand + 1, false, 1)
	if card_number_in_hand + 2 <= number_of_cards_in_hand:
		move_neighbor_card(card_number_in_hand + 2, false, 0.25)
		
func reset_neighbors():
	if card_number_in_hand - 1 >= 0:
		Reset_Card(card_number_in_hand - 1) #true is left
	if card_number_in_hand - 2 >= 0:
		Reset_Card(card_number_in_hand - 2) #true is left
	if card_number_in_hand + 1 <= number_of_cards_in_hand:
		Reset_Card(card_number_in_hand + 1)
	if card_number_in_hand + 2 <= number_of_cards_in_hand:
		Reset_Card(card_number_in_hand + 2)

func move_neighbor_card(card_number_in_hand, Left, SpreadFactor):
	neighbor_card = $'../'.get_child(card_number_in_hand)
	var new_position;
	if Left:
		new_position = neighbor_card.resting_position - SpreadFactor*Vector2(65,0)
	else:
		new_position = neighbor_card.resting_position + SpreadFactor*Vector2(65,0)
	neighbor_card.set_state(ReOrganiseHand, new_position, null, null)

func set_state(new_state, new_position, new_rotation, new_scale):
	starting_position = position
	starting_rotation = rotation
	starting_scale = scale
	t = 0
	if new_position != null:
		target_position = new_position
	if new_scale != null:
		target_scale = new_scale
	if new_rotation != null:
		target_rotation = new_rotation
	state = new_state
	
func set_new_resting_position(new_position, new_rotation):
	resting_position = new_position
	resting_rotation = new_rotation
	
func move_using_tween(time):
	var trans = Tween.TRANS_CUBIC
	if tween:
		tween.kill()
		trans = Tween.EASE_OUT
	tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, time).set_trans(trans)
	

func process_move_linear(delta, totaltime):
	if t <= 1: # Interpolate uses a scale from 0 to 1, so this is always 1
		if !tween:
			position = starting_position.lerp(target_position, t)
		rotation = starting_rotation * (1-t) + target_rotation * t
		t += delta/float(totaltime) # DRAWTIME is in seconds
		scale = starting_scale * (1-t) + target_scale*t
	else:
		position = target_position
		rotation = target_rotation
		scale = target_scale
		if tween:
			tween.kill()
			tween = null


func _on_focus_gui_input(event: InputEvent) -> void:
	match state:
		FocusInHand:
			if event.is_action_pressed("leftclick"):
				set_state(InMouse, null, null, resting_scale)
				Global.selected_card = card_info
		InMouse:
			if event.is_action_pressed("leftclick"):
				var new_position = resting_position
				new_position.y = get_viewport_rect().size.y - card_size.y*ZoomInSize
				set_state(FocusInHand, new_position, 0, resting_scale * 2)
				Global.selected_card = Global.NO_CARD
