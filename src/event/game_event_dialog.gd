extends Node2D

var current_event: GameEvent
var completed_events: Array[GameEvent] = []

signal on_upgrades_selected

var card_database: DataFetcher

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer.position = Constants.VIEWPORT_SIZE / 2 - $PanelContainer.size / 2
	card_database = preload("res://src/cards/cards_database.gd").new()

func generate_random_event():
	# For now hardcode dream of emptiness
	var events = card_database.get_all_event()
	events.shuffle()
	for event in events:
		if !completed_events.has(event) and (event.prerequisite == null or completed_events.has(event.prerequisite)):
			current_event = event
			break
	completed_events.append(current_event)
	update_interface()

func update_interface():
	if current_event == null:
		return
	$PanelContainer/VBox/Title.text = current_event.name
	$PanelContainer/VBox/Description.text = current_event.text
	
	update_option(current_event.flavor_text_1, current_event.option1, $PanelContainer/VBox/Option1Button)
	update_option(current_event.flavor_text_2, current_event.option2, $PanelContainer/VBox/Option2Button)
	update_option(current_event.flavor_text_3, current_event.option3, $PanelContainer/VBox/Option3Button)

func update_option(flavor: String, upgrades: Array[Upgrade], button: Button):
	if upgrades.size() == 0:
		button.visible = false
	else:
		button.visible = true
		var text = flavor
		for upgrade in upgrades:
			if upgrade.text.length() > 0:
				if text.length() == flavor.length(): # if this is the first upgrade with text
					text += " ("
				text += upgrade.text
		if text.length() > flavor.length(): # if at least one upgrade had text
			text += ")"
		button.text = text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$PanelContainer.position = Constants.VIEWPORT_SIZE / 2 - $PanelContainer.size / 2


func _on_option_1_button_pressed() -> void:
	on_upgrades_selected.emit(current_event.option1)

func _on_option_2_button_pressed() -> void:
	on_upgrades_selected.emit(current_event.option2)

func _on_option_3_button_pressed() -> void:
	on_upgrades_selected.emit(current_event.option3)
