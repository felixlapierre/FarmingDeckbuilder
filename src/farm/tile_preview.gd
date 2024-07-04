extends Node2D

@onready var state_label = $VBox/StatsPanel/VBox/StateLabel
@onready var yield_label = $VBox/StatsPanel/VBox/YieldLabel
@onready var duration_label = $VBox/StatsPanel/VBox/DurationLabel
@onready var card_base = $VBox/CardBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup(tile: Tile):
	state_label.text = "State: " + str(Enums.TileState.find_key(tile.state))
	if tile.seed != null:
		card_base.set_card_info(tile.seed)
		card_base.visible = true
	elif tile.structure != null:
		card_base.set_card_info(tile.structure)
		card_base.visible = true
	else:
		card_base.visible = false
	
	if tile.seed_grow_time != null and tile.seed_grow_time != 0:
		duration_label.text = "Duration: " + str(tile.current_grow_progress) + " / " + str(tile.seed_grow_time)
		duration_label.visible = true
	else:
		duration_label.visible = false
	
	if tile.current_yield != null and tile.current_yield != 0.0:
		yield_label.visible = true
		yield_label.text = "Yield: " + str(snapped(tile.current_yield, 0.01))
	else:
		yield_label.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
