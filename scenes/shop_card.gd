extends Control

@export var card_data: CardData
@export var cost: int
@export var disabled: bool
signal on_clicked

var CardBase = preload("res://scenes/card_base.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var card_node = CardBase.instantiate()
	card_node.set_card_info(card_data)
	card_node.on_clicked.connect(on_card_clicked)
	card_node.set_state(CardState.InShop, null, null, null)
	$VBox.add_child(card_node)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cost == 0:
		$VBox/CostLabel/Label.text = ""
		$VBox/CostLabel/TextureRect.visible = false
	#elif cost > 0:
	#	$VBox/CostLabel/TextureRect.visible = true
	#	$VBox/CostLabel/Label.text = str(cost)
	#elif cost < 0:
	#	$VBox/CostLabel/TextureRect.visible = true
	#	$VBox/CostLabel/Label.text = "+" + str(cost)
	#$VBox.get_child(1).visible = !disabled

func on_card_clicked(card):
	if !disabled:
		on_clicked.emit(card)
