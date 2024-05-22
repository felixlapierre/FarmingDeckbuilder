extends MarginContainer

var CardDatabase 
var Cardname = "Blueberry"
var CardInfo;
var CardImg = "res://assets/1616tinygarden/objects.png"
const CardSize = Vector2(125, 175)

var startpos = 0
var targetpos = 0
var startscale: Vector2
var Cardpos: Vector2
var orig_scale = CardSize / size
var ZoomInSize = 2
var t = 0
var startrot = 0
var targetrot = 0
var tween
var tweening = false
var setup = true
var reorganize_neighbors = true
var NumberCardsHand = 0
var CardNumber = 0;
var NeighborCard;
var Move_Neighbor_Card_Check = false

var DRAWTIME = 0.5
var ZOOMTIME = 0.3

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
	CardDatabase = preload("res://scripts/cards_database.gd")
	CardInfo = CardDatabase.DATA[CardDatabase.get(Cardname)]
	print(CardInfo)
	
	var CardSize = size
	$CardBorder.scale *= CardSize / $CardBorder.texture.get_size()
	$CardIcon.texture = load(CardImg)
	$CardIcon.region_enabled = true
	$CardIcon.set_region_rect(Rect2(CardInfo[8] * 16, 0, 16, 16))
	$CardIcon.position = $CardBorder.texture.get_size() / 2
	$CardIcon.position.y /= 2
	$Focus.scale *= CardSize / $Focus.size
	
	$HBoxContainer/VBoxContainer/BottomBar/TypeLabel.text = CardInfo[0]
	$HBoxContainer/VBoxContainer/TopBar/CardNameLabel.text = CardInfo[1]
	$HBoxContainer/VBoxContainer/TopBar/CardCostLabel.text = str(CardInfo[2])
	$HBoxContainer/VBoxContainer/BottomBar/YieldLabel.text = str(CardInfo[3]) + " Yld / "
	$HBoxContainer/VBoxContainer/BottomBar/TimeLabel.text = str(CardInfo[4]) + " Wks"
	$HBoxContainer/VBoxContainer/DescriptionLabel.text = CardInfo[7]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		InHand:
			pass
		InPlay:
			pass
		InMouse:
			pass
		FocusInHand:
			if setup:
				Setup()
			if t <= 1: # Interpolate uses a scale from 0 to 1, so this is always 1
				position = startpos.lerp(targetpos, t)
				rotation = startrot * (1-t) + 0 * t
				t += delta/float(ZOOMTIME/2)
				scale = startscale * (1-t) + orig_scale*2*t
				if reorganize_neighbors:
					reorganize_neighbors = false
					NumberCardsHand = $'../../'.NumberCardsHand - 1
					if CardNumber - 1 >= 0:
						Move_Neighbor_Card(CardNumber - 1, true, 1) #true is left
					if CardNumber - 2 >= 0:
						Move_Neighbor_Card(CardNumber - 2, true, 0.25) #true is left
					if CardNumber + 1 <= NumberCardsHand:
						Move_Neighbor_Card(CardNumber + 1, false, 1)
					if CardNumber + 2 <= NumberCardsHand:
						Move_Neighbor_Card(CardNumber + 2, false, 0.25)
			else:
				position = targetpos # In case we need to correct
				rotation = 0
				scale = orig_scale*2
		MoveDrawnCardToHand:
			if t <= 1: # Interpolate uses a scale from 0 to 1, so this is always 1
				if !tween:
					tween = get_tree().create_tween()
					position = startpos
					tween.tween_property(self, "position", targetpos, DRAWTIME).set_trans(Tween.TRANS_CUBIC)
					
				#position = startpos.lerp(targetpos, t)
				rotation = startrot * (1-t) + targetrot * t
				t += delta/float(DRAWTIME) # DRAWTIME is in seconds
			else:
				position = targetpos # In case we need to correct
				rotation = targetrot
				scale = orig_scale
				state = InHand
				t = 0 # Reset to 0 so we can reuse this later
		ReOrganiseHand:
			if setup:
				Setup()
			if t <= 1: # Interpolate uses a scale from 0 to 1, so this is always 1
				if Move_Neighbor_Card_Check:
					Move_Neighbor_Card_Check = false
				position = startpos.lerp(targetpos, t)
				rotation = startrot * (1-t) + targetrot * t
				t += delta/float(DRAWTIME/2) # DRAWTIME is in seconds
				scale = startscale * (1-t) + orig_scale*t
				if reorganize_neighbors == false:
					reorganize_neighbors = true
					if CardNumber - 1 >= 0:
						Reset_Card(CardNumber - 1) #true is left
					if CardNumber - 2 >= 0:
						Reset_Card(CardNumber - 2) #true is left
					if CardNumber + 1 <= NumberCardsHand:
						Reset_Card(CardNumber + 1)
					if CardNumber + 2 <= NumberCardsHand:
						Reset_Card(CardNumber + 2)
			else:
				position = targetpos # In case we need to correct
				rotation = targetrot
				scale = orig_scale
				state = InHand
				t = 0 # Reset to 0 so we can reuse this later

func Setup():
	startpos = position
	startrot = rotation
	startscale = orig_scale
	t = 0
	setup = false
	
func Reset_Card(CardNumber):
	if Move_Neighbor_Card_Check == false:
		NeighborCard = $'../'.get_child(CardNumber)
		# Allows mousing directly from one card to another
		if NeighborCard.state != FocusInHand:
			NeighborCard.state = ReOrganiseHand
			NeighborCard.targetpos = NeighborCard.Cardpos
			NeighborCard.setup = true

func _on_focus_mouse_entered() -> void:
	match state:
		InHand, ReOrganiseHand:
			setup = true
			targetpos = Cardpos
			targetpos.y = get_viewport_rect().size.y - CardSize.y*ZoomInSize
			state = FocusInHand


func _on_focus_mouse_exited() -> void:
	match state:
		FocusInHand:
			setup = true
			targetpos = Cardpos
			state = ReOrganiseHand

func Move_Neighbor_Card(CardNumber, Left, SpreadFactor):
	print(CardNumber)
	NeighborCard = $'../'.get_child(CardNumber)
	if Left:
		NeighborCard.targetpos = NeighborCard.Cardpos - SpreadFactor*Vector2(65,0)
	else:
		NeighborCard.targetpos = NeighborCard.Cardpos + SpreadFactor*Vector2(65,0)
	NeighborCard.setup = true
	NeighborCard.state = ReOrganiseHand
	Move_Neighbor_Card_Check = true
