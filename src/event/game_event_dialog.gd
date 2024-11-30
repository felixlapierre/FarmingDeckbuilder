extends Node2D

var current_event: GameEvent
var completed_events: Array[String] = []
var always_do_event = load("res://src/event/script/mage_upgrade.gd").new()

signal on_upgrades_selected

var card_database: DataFetcher
var deck: Array[CardData] = []
var turn_manager: TurnManager = null

var custom_event: CustomEvent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer.position = Constants.VIEWPORT_SIZE / 2 - $PanelContainer.size / 2
	card_database = preload("res://src/cards/cards_database.gd").new()

func setup(p_deck: Array[CardData], p_turn_manager: TurnManager):
	deck = p_deck
	turn_manager = p_turn_manager

func generate_random_event():
	if always_do_event != null and !completed_events.has(always_do_event.name):
		custom_event = always_do_event
		custom_event.setup(turn_manager, $"../../", card_database)
	else:
		# Prioritize custom events
		var custom_events = card_database.get_custom_events()
		var options = []
		for event in custom_events:
			event.setup(turn_manager, $"../../", card_database)
			if event.check_prerequisites() and !completed_events.has(event.name):
				options.append(event)
		
		if options.size() > 0:
			options.shuffle()
			custom_event = options[0]

	if custom_event != null:
		completed_events.append(custom_event.name)
		update_interface()
		return

	if always_do_event != null and !completed_events.has(always_do_event.name):
		current_event = always_do_event
	else:
		var events = card_database.get_all_event()
		events.shuffle()
		for event in events:
			if !completed_events.has(event.name)\
				and (event.prerequisite == null or completed_events.has(event.prerequisite.name))\
				and event.check_upgrade_prerequisite(deck, turn_manager):
				current_event = event
				break

	completed_events.append(current_event.name)
	update_interface()

func update_interface():	
	if custom_event != null:
		$PanelContainer/Margin/VBox/HBox/Title.text = custom_event.name
		$PanelContainer/Margin/VBox/Description.text = custom_event.text
		
		var options = custom_event.get_options()
		$PanelContainer/Margin/VBox/Option1Button.text = options[0].name
		if options.size() >= 2:
			$PanelContainer/Margin/VBox/Option2Button.text = options[1].name
		$PanelContainer/Margin/VBox/Option2Button.visible = options.size() >= 2
		if options.size() >= 3:
			$PanelContainer/Margin/VBox/Option3Button.text = options[2].name
		$PanelContainer/Margin/VBox/Option3Button.visible = options.size() >= 3
		return
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
	if custom_event != null:
		custom_event.get_options()[0].on_select.call()
		visible = false
	else:
		on_upgrades_selected.emit(current_event.option1)

func _on_option_2_button_pressed() -> void:
	if custom_event != null and custom_event.get_options().size() > 1:
		custom_event.get_options()[1].on_select.call()
		visible = false
	else:
		on_upgrades_selected.emit(current_event.option2)

func _on_option_3_button_pressed() -> void:
	if custom_event != null and custom_event.get_options().size() > 1:
		custom_event.get_options()[2].on_select.call()
		visible = false
	else:
		on_upgrades_selected.emit(current_event.option3)


func _on_click_out_button_pressed():
	visible = false
