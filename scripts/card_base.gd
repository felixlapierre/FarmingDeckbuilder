extends MarginContainer

var CardDatabase 
var Cardname = "Blueberry"
var CardInfo;
var CardImg = "res://assets/1616tinygarden/objects.png"

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
	pass
