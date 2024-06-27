extends Node2D

var event_manager: EventManager

var good_fortune: Fortune
var bad_fortune: Fortune

signal on_close

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer.position = Constants.VIEWPORT_SIZE / 2 - $PanelContainer.size / 2

func setup(p_event_manager: EventManager):
	event_manager = p_event_manager

func create_fortunes():
	good_fortune = Fortune.new("Fast Ritual", Fortune.FortuneType.ReduceRitualTarget, "Reduce the yield required to finish the ritual by 20")
	#bad_fortune = preload("res://src/fortune/data/end_turn_swap_colors.gd").new()
	bad_fortune = preload("res://src/fortune/data/end_turn_obliviate.gd").new()
	#bad_fortune = preload("res://src/fortune/data/target_growing_plants.gd").new()
	#bad_fortune = Fortune.new("Weeds", Fortune.FortuneType.Weeds, "Your farm starts with weeds that will take up space until cleared")
	
	$PanelContainer/VBox/HBox/GoodFortune/VBox/Name.text = good_fortune.name
	$PanelContainer/VBox/HBox/GoodFortune/VBox/RichTextLabel.text = good_fortune.text
	
	$PanelContainer/VBox/HBox/BadFortune/VBox/Name.text = bad_fortune.name
	$PanelContainer/VBox/HBox/BadFortune/VBox/RichTextLabel.text = bad_fortune.text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func register_fortunes():
	if good_fortune != null:
		good_fortune.register_fortune(event_manager)
	if bad_fortune != null:
		bad_fortune.register_fortune(event_manager)

func unregister_fortunes():
	if good_fortune != null:
		good_fortune.unregister_fortune(event_manager)
	if bad_fortune != null:
		bad_fortune.unregister_fortune(event_manager)

func _on_click_out_button_pressed() -> void:
	on_close.emit()
