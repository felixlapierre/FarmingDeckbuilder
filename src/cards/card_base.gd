extends MarginContainer

var card_info;
var card_image = "res://assets/1616tinygarden/objects.png"
var card_database
var card_size = Vector2(200, 280)

var starting_position # For animating movement, start position of the card
var target_position # For animating movement, position card should end up at
var resting_position: Vector2 # Card comes back to rest at this position when we need to unfocus etc

var starting_scale: Vector2 # For animating scale, start scale
var resting_scale = Vector2(1, 1)
var target_scale;

var starting_rotation = 0
var target_rotation = 0
var resting_rotation = 0

var ZoomInSize = 1.8
var t = 0

var tween

var number_of_cards_in_hand = 0
var card_number_in_hand = 0;
var neighbor_card;

var DRAWTIME = 0.5
var ZOOMTIME = 0.3
var HAND_TOP_Y

var state = Enums.CardState.InHand

signal on_clicked

var CARD_ICON
var SIZE_LABEL
# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	var card_size = size
	HAND_TOP_Y = Constants.VIEWPORT_SIZE.y - card_size.y
	$Focus.scale *= card_size / $Focus.size

func set_card_info(card_data):
	card_info = card_data
	CARD_ICON = $HBoxContainer/VBoxContainer/ImageMargin/ImageCont/CardIconCont/CardIcon
	SIZE_LABEL = $HBoxContainer/VBoxContainer/ImageMargin/ImageCont/SizeCont/SizeLabel
	match card_info.type:
		"SEED":
			var texture = AtlasTexture.new()
			texture.atlas = load("res://assets/1616tinygarden/objects.png")
			texture.set_region(Rect2(Vector2(card_data.seed_texture * 16, 0), Vector2(16, 16)))
			CARD_ICON.texture = texture
			$HBoxContainer/VBoxContainer/BottomBar/YieldLabel.text = str(card_info.yld)\
				+ " (" + str(card_info.yld * card_info.size) + ")"
			$HBoxContainer/VBoxContainer/BottomBar/TimeLabel.text = str(card_info.time)
		"ACTION", "STRUCTURE":
			CARD_ICON.texture = card_info.texture
			$HBoxContainer/VBoxContainer/BottomBar/YieldLabel.visible = false
			$HBoxContainer/VBoxContainer/BottomBar/YieldTexture.visible = false
			$HBoxContainer/VBoxContainer/BottomBar/TimeLabel.visible = false
			$HBoxContainer/VBoxContainer/BottomBar/TimeTexture.visible = false
	if card_info.type == "STRUCTURE":
		$CardBorder.modulate = Color8(135, 206, 250)
	$HBoxContainer/VBoxContainer/BottomBar/TypeLabel.text = card_info.type
	$HBoxContainer/VBoxContainer/TopBar/CardNameLabel.text = card_info.name
	$HBoxContainer/VBoxContainer/TopBar/CardCostLabel.text = str(card_info.cost)
	$HBoxContainer/VBoxContainer/DescriptionLabel.text = card_info.get_description()
	if card_info.size == 0:
		$HBoxContainer/VBoxContainer/ImageMargin/ImageCont/SizeCont.visible = false
	else:
		SIZE_LABEL.text = str(card_info.size) if card_info.size != -1 else "All"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		Enums.CardState.InShop:
			pass
		Enums.CardState.InHand:
			pass
		Enums.CardState.InPlay:
			pass
		Enums.CardState.InMouse:
			var mouse_position = get_global_mouse_position() - card_size
			if mouse_position.y < HAND_TOP_Y:
				target_position = Constants.VIEWPORT_SIZE / Vector2(16, 4)
				scale = resting_scale * 1.7
				target_scale = scale
			else:
				target_position = mouse_position
				scale = resting_scale
				target_scale = scale
			process_move_linear(delta, 0.1)
		Enums.CardState.FocusInHand:
			process_move_linear(delta, ZOOMTIME/2)
		Enums.CardState.MoveDrawnCardToHand:
			if t > 1:
				state = Enums.CardState.InHand
			process_move_linear(delta, DRAWTIME)
		Enums.CardState.ReOrganiseHand:
			if t > 1:
				state = Enums.CardState.InHand
			process_move_linear(delta, 0.3)
		Enums.CardState.MoveToDiscard:
			if t > 1:
				$"../../".finish_discard(self)
			process_move_linear(delta, 0.5)

func reset_starting_position():
	starting_position = position
	starting_rotation = rotation
	starting_scale = scale
	t = 0
	
func Reset_Card(card_number_in_hand):
	neighbor_card = $'../'.get_child(card_number_in_hand)
	neighbor_card = $'../'.get_child(card_number_in_hand)
	# Allows mousing directly from one card to another
	if neighbor_card.state != Enums.CardState.FocusInHand:
		neighbor_card.state = Enums.CardState.ReOrganiseHand
		neighbor_card.target_position = neighbor_card.resting_position
		neighbor_card.reset_starting_position()

func _on_focus_mouse_entered() -> void:
	match state:
		Enums.CardState.InHand, Enums.CardState.ReOrganiseHand:
			var new_position = resting_position
			new_position.y = Constants.VIEWPORT_SIZE.y - card_size.y*ZoomInSize*0.9
			set_state(Enums.CardState.FocusInHand, new_position, 0, resting_scale * ZoomInSize)
			move_neighbors()
			Global.selected_card = null


func _on_focus_mouse_exited() -> void:
	match state:
		Enums.CardState.FocusInHand:
			set_state(Enums.CardState.ReOrganiseHand, resting_position, resting_rotation, resting_scale)
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
	neighbor_card.set_state(Enums.CardState.ReOrganiseHand, new_position, null, null)

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
	if event.is_action_pressed("leftclick"):
		match state:
			Enums.CardState.FocusInHand:
				set_state(Enums.CardState.InMouse, null, null, resting_scale)
				Global.selected_card = card_info
				Global.shape = Helper.get_default_shape(card_info.size)
				Global.rotate = 0
			Enums.CardState.InMouse:
				var new_position = resting_position
				new_position.y = Constants.VIEWPORT_SIZE.y - card_size.y*ZoomInSize
				set_state(Enums.CardState.FocusInHand, new_position, 0, resting_scale * ZoomInSize)
				Global.selected_card = null
			Enums.CardState.InShop:
				on_clicked.emit(self)

func _input(event: InputEvent) -> void:
	if state == Enums.CardState.InMouse and event.is_action_pressed("rightclick"):
		set_state(Enums.CardState.ReOrganiseHand, resting_position, resting_rotation, resting_scale)
		reset_neighbors()
		Global.selected_card = null