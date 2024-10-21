extends Node2D

var current_event: GameEvent
var completed_events: Array[GameEvent] = []
var always_do_event: GameEvent = preload("res://src/event/data/blight_offering.tres")

signal on_upgrades_selected

var card_database: DataFetcher
var deck: Array[CardData] = []
var turn_manager: TurnManager = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer.position = Constants.VIEWPORT_SIZE / 2 - $PanelContainer.size / 2
	card_database = preload("res://src/cards/cards_database.gd").new()

func setup(p_deck: Array[CardData], p_turn_manager: TurnManager):
	deck = p_deck
	turn_manager = p_turn_manager

func generate_random_event():
	if always_do_event != null and !completed_events.has(always_do_event):
		current_event = always_do_event
	else:
		var events = card_database.get_all_event()
		events.shuffle()
		for event in events:
			if !completed_events.has(event)\
				and (event.prerequisite == null or completed_events.has(event.prerequisite))\
				and event.check_upgrade_prerequisite(deck, turn_manager):
				current_event = event
				break

	completed_events.append(current_event)
	update_interface()

func update_interface():
	if current_event == null:
		return
	$PanelContainer/Margin/VBox/HBox/Title.text = current_event.name
	$PanelContainer/Margin/VBox/Description.text = current_event.text
	
	update_option(current_event.flavor_text_1, current_event.option1, $PanelContainer/Margin/VBox/Option1Button)
	update_option(current_event.flavor_text_2, current_event.option2, $PanelContainer/Margin/VBox/Option2Button)
	update_option(current_event.flavor_text_3, current_event.option3, $PanelContainer/Margin/VBox/Option3Button)

func update_option(flavor: String, upgrades: Array[Upgrade], button: Button):
	if upgrades.size() == 0:
		button.visible = false
	else:
		button.visible = true
		var text = flavor
		var tooltip = ""
		for upgrade in upgrades:
			if upgrade.text.length() > 0:
				if text.length() == flavor.length(): # if this is the first upgrade with text
					text += " ("
				text += upgrade.get_text()
			if upgrade.get_tooltip().length() > 0:
				if tooltip.length() == 0:
					tooltip += upgrade.get_tooltip()
				else:
					tooltip += ". " + upgrade.get_tooltip()
		if text.length() > flavor.length(): # if at least one upgrade had text
			text += ")"
		button.text = text
		button.tooltip_text = tooltip 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$PanelContainer.position = Constants.VIEWPORT_SIZE / 2 - $PanelContainer.size / 2


func _on_option_1_button_pressed() -> void:
	on_upgrades_selected.emit(current_event.option1)

func _on_option_2_button_pressed() -> void:
	on_upgrades_selected.emit(current_event.option2)

func _on_option_3_button_pressed() -> void:
	on_upgrades_selected.emit(current_event.option3)


func _on_click_out_button_pressed():
	visible = false
