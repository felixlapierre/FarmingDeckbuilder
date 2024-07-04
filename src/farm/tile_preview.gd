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
		yield_label.text = "Yield: " + str(tile.current_yield)
		duration_label.text = "Duration: " + str(tile.current_grow_progress) + " / " + str(tile.seed_grow_time)
		yield_label.visible = true
		duration_label.visible = true
		card_base.visible = true
	elif tile.structure != null:
		card_base.set_card_info(tile.structure)
		yield_label.visible = false
		duration_label.visible = false
		card_base.visible = true
	else:
		yield_label.visible = false
		duration_label.visible = false
		card_base.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
