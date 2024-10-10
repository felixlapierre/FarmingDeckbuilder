extends Node
class_name Mastery

static var RitualTarget: int = 0
static var BlightAttack: int = 0
static var Misfortune: int = 0
static var HidePreview: int = 0
static var BlockShop: int = 0
static var CardRemoveCost: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

static func save_data():
	var data = {}
	data.RitualTarget = RitualTarget
	data.BlightAttack = BlightAttack
	data.Misfortune = Misfortune
	data.HidePreview = HidePreview
	data.BlockShop = BlockShop
	data.CardRemoveCost = CardRemoveCost
	return data

static func load_data(data):
	RitualTarget = data.RitualTarget
	BlightAttack = data.BlightAttack
	Misfortune = data.Misfortune
	HidePreview = data.HidePreview
	BlockShop = data.BlockShop
	CardRemoveCost = data.CardRemoveCost

static func get_total_mastery():
	return RitualTarget + BlightAttack + Misfortune + HidePreview + BlockShop + CardRemoveCost

static func reset():
	RitualTarget = 0
	BlightAttack = 0
	Misfortune = 0
	HidePreview = 0
	BlockShop = 0
	CardRemoveCost = 0
