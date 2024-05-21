extends MarginContainer

var CardDatabase 
var Cardname = "Blueberry"
var CardInfo;
var CardImg = "res://assets/1616tinygarden/objects.png"

var startpos = 0
var targetpos = 0
var t = 0
var DRAWTIME = 0.5
var startrot = 0
var targetrot = 0

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
			pass
		MoveDrawnCardToHand:
			if t <= 1: # Interpolate uses a scale from 0 to 1, so this is always 1
				position = startpos.lerp(targetpos, t)
				rotation = startrot * (1-t) + targetrot * t
				t += delta/float(DRAWTIME) # DRAWTIME is in seconds
			else:
				position = targetpos # In case we need to correct
				rotation = targetrot
				state = InHand
				t = 0 # Reset to 0 so we can reuse this later
		ReOrganiseHand:
			if t <= 1: # Interpolate uses a scale from 0 to 1, so this is always 1
				position = startpos.lerp(targetpos, t)
				rotation = startrot * (1-t) + targetrot * t
				t += delta/float(DRAWTIME/2) # DRAWTIME is in seconds
			else:
				position = targetpos # In case we need to correct
				rotation = targetrot
				state = InHand
				t = 0 # Reset to 0 so we can reuse this later
