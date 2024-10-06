extends Node2D

class_name UserInterface

signal apply_upgrade
signal end_turn_button_pressed
signal on_skip
signal on_next_year
signal on_blight_removed
signal on_main_menu
signal farm_preview_show
signal farm_preview_hide
signal after_farm_expanded

@export var turn_manager: TurnManager

var shop_structure_place_callback
var deck: Array[CardData]
var cards: Cards
var turn_ending = false
var mage_fortune: MageAbility = null

var SELECT_CARD = preload("res://src/cards/select_card.tscn")
var cards_database = preload("res://src/cards/cards_database.gd")
var PickOption = preload("res://src/ui/pick_option.tscn")
var FORTUNE_HOVER = preload("res://src/fortune/fortune_hover.tscn")

@onready var shop: Shop = $Shop
@onready var tooltip: Tooltip = $Tooltip
@onready var year_label = $UI/Stats/VBox/YearLabel
@onready var turn_label = $UI/Stats/VBox/TurnLabel
@onready var energy_hbox = $UI/Stats/VBox/EnergyHbox
@onready var cards_hbox = $UI/Stats/VBox/CardsHbox
@onready var AlertDisplay: Alert = $AlertContainer
@onready var GameEventDialog = $Winter/GameEventDialog

@onready var BlightPanel = $UI/BlightPanel
@onready var Stats = $UI/Stats
@onready var UpgradeButton = $Winter/FarmUpgradeButton
@onready var FortuneTellerButton = $Winter/FortuneTellerButton
@onready var EventPanel = $Winter/EventPanel
@onready var EventButton = $Winter/EventPanel/VB/EventButton
@onready var WinterUi = $Winter
@onready var FarmingUi = $UI
@onready var FortuneTeller = $FortuneTeller
@onready var EndScreen = $EndScreen

var end_year_alert_text = "Ritual Complete! Time to rest and prepare for the next year"
var structure_place_text = "Click on the farm tile where you'd like to place the structure"
var no_energy_text = "[color=red]Not Enough Energy![/color]"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in Constants.MAX_BLIGHT:
		var sprite = TextureRect.new()
		sprite.texture = load("res://assets/custom/BlightEmpty.png")
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		$UI/DamagePanel/BlightDamage.add_child(sprite)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $UI/RTFPanel != null:
		$UI/RTFPanel.visible = false
		var shape = Enums.CursorShape.keys()[Global.shape]
		$UI/RTFPanel/VBox/ShapeLabel.text = "Shape: " + shape

func setup(p_event_manager: EventManager, p_turn_manager: TurnManager, p_deck: Array[CardData], p_cards: Cards):
	$FortuneTeller.setup(p_event_manager)
	turn_manager = p_turn_manager
	deck = p_deck
	cards = p_cards
	GameEventDialog.setup(deck, turn_manager)
	$Shop.setup(deck, turn_manager)
	register_tooltips()
	$Tutorial.setup(p_event_manager)
	$UI/AttackPreview.setup(turn_manager, mage_fortune, p_event_manager)

# Start and end year
func end_year():
	AlertDisplay.clear(end_year_alert_text)
	$UI.visible = false
	$Winter.visible = true
	$UpgradeShop.lock = false
	$Winter/EventPanel/VB/EventButton.disabled = false
	GameEventDialog.generate_random_event()
	$Shop.fill_shop()
	$FortuneTeller.unregister_fortunes()
	$FortuneTeller.create_fortunes()
	create_fortune_display()
	update()
	$Tutorial.on_winter()
	$Tutorial.position.x = 1234
	
func start_year():
	$UI/SkipButton.visible = Settings.DEBUG
	$FortuneTeller.register_fortunes()
	turn_manager.start_new_year($FortuneTeller.attack_pattern);
	$UI/AttackPreview.set_attack($FortuneTeller.attack_pattern)
	$UI.visible = true
	$Winter.visible = false
	AlertDisplay.clear(end_year_alert_text)
	$Tutorial.position.x = 1368
	create_fortune_display()
	update_damage()
	update()

# Update UI display
func update():
	$UI/Stats/VBox/YearLabel.text = "Year: " + str(turn_manager.year) + " / " + str(Global.FINAL_YEAR)
	$UI/Stats/VBox/TurnLabel.text = "Week: " + str(turn_manager.week) + " / 12"
	$UI/Stats/VBox/EnergyHbox/EnergyLabel.text = "Energy: " + str(turn_manager.energy) + " / " + str(Constants.MAX_ENERGY + int(float(Global.ENERGY_FRAGMENTS) / 3))
	$UI/EnergyDisplay.set_energy(turn_manager.energy)
	for child in $UI/Stats/VBox/EnergyHbox/Fragments.get_children():
		$UI/Stats/VBox/EnergyHbox/Fragments.remove_child(child)
	for i in range(Global.ENERGY_FRAGMENTS % 3):
		var fragment = TextureRect.new()
		fragment.texture = load("res://assets/custom/EnergyFrag.png")
		fragment.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		$UI/Stats/VBox/EnergyHbox/Fragments.add_child(fragment)
	
	$UI/Stats/VBox/CardsHbox/CardsLabel.text = "Cards: " + str(turn_manager.get_cards_drawn()) + " / " + str(Constants.BASE_HAND_SIZE + int(float(Global.SCROLL_FRAGMENTS) / 3))
	for child in $UI/Stats/VBox/CardsHbox/Fragments.get_children():
		$UI/Stats/VBox/CardsHbox/Fragments.remove_child(child)
	for i in range(Global.SCROLL_FRAGMENTS % 3):
		var fragment = TextureRect.new()
		fragment.texture = load("res://assets/custom/CardFragment.png")
		fragment.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		$UI/Stats/VBox/CardsHbox/Fragments.add_child(fragment)

	#Blight Panels
	#$UI/BlightPanel.visible = turn_manager.target_blight > 0 or turn_manager.purple_mana > 0
#
	#$UI/BlightPanel/AttackParticles.emitting = false
	#if turn_manager.target_blight > 0:
		#$UI/BlightPanel/VBox/BlightCounter/Label.text = str(turn_manager.purple_mana) + " / " + str(turn_manager.target_blight) + " [img]res://assets/custom/PurpleMana.png[/img]"
	#else:
		#$UI/BlightPanel/VBox/BlightCounter/Label.text = str(turn_manager.purple_mana) + "[img]res://assets/custom/PurpleMana.png[/img]"
	#if turn_manager.purple_mana < turn_manager.target_blight:
		#$UI/BlightPanel/VBox/AttackLabel.text = "Blight Attack!"
		#$UI/BlightPanel/AttackParticles.emitting = true
	#elif turn_manager.purple_mana > turn_manager.target_blight and turn_manager.flag_defer_excess:
		#$UI/BlightPanel/VBox/AttackLabel.text = "Defer: " + str(turn_manager.purple_mana - turn_manager.target_blight) + Helper.blue_mana()
	#elif turn_manager.purple_mana > turn_manager.target_blight and turn_manager.target_blight == 0 and mage_fortune.name != "Lunar Priest":
		#$UI/BlightPanel/VBox/AttackLabel.text = "Wasted"
	#elif turn_manager.purple_mana > turn_manager.target_blight and mage_fortune.name == "Lunar Priest":
		#$UI/BlightPanel/VBox/AttackLabel.text = "Excess: " + str((turn_manager.purple_mana - turn_manager.target_blight) * mage_fortune.strength) + Helper.mana_icon()
	#else:
		#$UI/BlightPanel/VBox/AttackLabel.text = "Safe!"

	#Next turn blight
	#$UI/NextBlightPanel.visible = turn_manager.next_turn_blight > 0
	#$UI/NextBlightPanel/NextTurnLabel.text = "Attack\nNext Turn: " + str(turn_manager.next_turn_blight) + " [img]res://assets/custom/PurpleMana.png[/img]"
	#if turn_manager.flag_defer_excess:
		#var next_turn_amount = turn_manager.purple_mana - turn_manager.target_blight
		#$UI/NextBlightPanel/NextTurnLabel.text = "Attack\nNext Turn: [color=9f78e3]" + str(max(turn_manager.next_turn_blight - next_turn_amount, 0)) + "[/color]"
	$UI/AttackPreview.update()
	
	$UI/RitualPanel/RitualCounter/Label.text = "[right]" + str(turn_manager.get_current_ritual()) + " /" + str(turn_manager.total_ritual)
	$Shop.update_labels()
	$Winter/FarmUpgradeButton.disabled = $UpgradeShop.lock or ![4, 7, 10].has(turn_manager.year)
	# Temporarily disable this QOL for testing
	$Winter/NextYearButton.disabled = !next_year_allowed()
	if GameEventDialog.current_event != null:
		$Winter/EventPanel/VB/EventNameLabel.text = GameEventDialog.current_event.name
	register_tooltips()
	$Tutorial.check_visible()
	$UI/Deck/DeckCount.text = "Deck: " + str(cards.get_deck_info().size())
	$UI/Deck/DiscardCount.text = "Discard: " + str(cards.get_discard_info().size())
	$Obelisk.value = turn_manager.ritual_counter
	
	$UpgradeShop.update()

# Fortune Teller
func _on_fortune_teller_button_pressed() -> void:
	$FortuneTeller.visible = true

func _on_fortune_teller_on_close() -> void:
	$FortuneTeller.visible = false

# Event
func _on_event_button_pressed() -> void:
	GameEventDialog.visible = true
	
func _on_game_event_dialog_on_upgrades_selected(upgrades: Array[Upgrade]) -> void:
	for upgrade in upgrades:
		if upgrade.type == Upgrade.UpgradeType.AddCommonCard or upgrade.type == Upgrade.UpgradeType.AddRareCard or upgrade.type == Upgrade.UpgradeType.AddUncommonCard:
			var rarity = "common"
			match upgrade.type:
				Upgrade.UpgradeType.AddRareCard:
					rarity = "rare"
				Upgrade.UpgradeType.AddUncommonCard:
					rarity = "uncommon"
			var cards;
			if Global.FARM_TYPE == "WILDERNESS":
				cards = cards_database.get_random_action_cards(rarity, 3)
			else:
				cards = cards_database.get_random_cards(rarity, 3)
			var pick_option_ui = PickOption.instantiate()
			GameEventDialog.add_sibling(pick_option_ui)
			var prompt = "Pick a card to add to your deck"
			pick_option_ui.setup(prompt, cards, func(selected):
				var add_card_upgrade = Upgrade.new()
				add_card_upgrade.type = Upgrade.UpgradeType.AddSpecificCard
				add_card_upgrade.card = selected.card_info
				apply_upgrade.emit(add_card_upgrade)
				$Winter.remove_child(pick_option_ui), func():
					$Winter.remove_child(pick_option_ui))
		elif upgrade.type == Upgrade.UpgradeType.AddEnhance\
			or upgrade.type == Upgrade.UpgradeType.AddEnhanceToRandom\
			or upgrade.type == Upgrade.UpgradeType.AddEnhanceToAll:
			
			var add_enhance = func(selected):
				if upgrade.type == Upgrade.UpgradeType.AddEnhance:
					select_card_to_enhance(selected)
				elif upgrade.type == Upgrade.UpgradeType.AddEnhanceToRandom:
					var cards = []
					for card in deck:
						if selected.is_card_eligible(card):
							cards.append(card)
					cards.shuffle()
					var card = cards[0]
					var new_card = card.apply_enhance(selected.copy())
					deck.erase(card)
					deck.append(new_card)
				elif upgrade.type == Upgrade.UpgradeType.AddEnhanceToAll:
					var old_cards = []
					var new_cards = []
					for card in deck:
						if selected.is_card_eligible(card):
							old_cards.append(card)
							var new_card = card.apply_enhance(selected.copy())
							new_cards.append(new_card)
					for card in old_cards:
						deck.erase(card)
					for card in new_cards:
						deck.append(card)
			if upgrade.enhance != null:
				add_enhance.call(upgrade.enhance)
			else:
				var enhances = cards_database.get_random_enhance("", 3, upgrade.type == Upgrade.UpgradeType.AddEnhanceToAll)
				var pick_option_ui = PickOption.instantiate()
				GameEventDialog.add_sibling(pick_option_ui)
				var prompt = "Pick an enhance to apply"
				pick_option_ui.setup(prompt, enhances, func(selected):
					add_enhance.call(selected)
					$Winter.remove_child(pick_option_ui),
					func():
						$Winter.remove_child(pick_option_ui))
		elif upgrade.type == Upgrade.UpgradeType.AddStructure:
			var structures = cards_database.get_random_structures(3)
			var pick_option_ui = PickOption.instantiate()
			GameEventDialog.add_sibling(pick_option_ui)
			var prompt = "Pick a structure to add to your farm"
			var on_pick = func(selected):
				$Winter.remove_child(pick_option_ui)
				_on_shop_on_structure_place(selected, func(): pass)
				$CancelStructure.visible = false
			var on_cancel = func(): $Winter.remove_child(pick_option_ui)
			pick_option_ui.setup(prompt, structures, on_pick, on_cancel)
		else:
			apply_upgrade.emit(upgrade)
	GameEventDialog.visible = false
	$Winter/EventPanel/VB/EventButton.disabled = true
	update()

# Upgrade Shop
func upgrade_shop_close():
	$UpgradeShop.visible = false
	update()

# Skip Button
func _on_skip_button_pressed() -> void:
	Global.selected_card = null
	on_skip.emit()

# Yield Preview
func _on_farm_tiles_on_preview_yield(args) -> void:
	var warning_waste_purple_text = "[color=ff0000]Warning![/color] [img]res://assets/custom/PurpleMana.png[/img] is lost at the end of the turn."
	AlertDisplay.clear(warning_waste_purple_text)
	var yellow = args.yellow
	var purple = args.purple
	$UI/Preview.visible = yellow + purple > 0
	$UI/Preview/Panel/HBox/PreviewYellow.text = "+" + str(yellow)
	$UI/Preview/Panel/HBox/PreviewPurple.text = "+" + str(purple)

	var blightamt = turn_manager.purple_mana + purple
	if purple != 0:
		if turn_manager.target_blight == 0 and mage_fortune.name != "Lunar Priest" and !args.defer:
			AlertDisplay.set_text(warning_waste_purple_text)

	if yellow != 0:
		$UI/RitualPanel/RitualCounter/Label.text = "[right][color=e5e831]"+str(turn_manager.get_current_ritual() + yellow) + " /" + str(turn_manager.total_ritual) + "[/color][/right]"
	else:
		$UI/RitualPanel/RitualCounter/Label.text = "[right]" + str(turn_manager.get_current_ritual()) + " /" + str(turn_manager.total_ritual)
# Winter
func set_winter_visible(visible):
	$Winter.visible = visible

func set_ui_visible(visible):
	$Winter/ShopButton.visible = visible
	$UI/Deck.visible = visible
	$UI/EndTurnButton.visible = visible
	$Shop.visible = visible
	$UI/RitualPanel/RitualCounter.visible = visible

# Shop
func _on_shop_on_structure_place(structure, callback) -> void:
	Global.selected_structure = structure
	Global.selected_card = null
	shop_structure_place_callback = func():
		AlertDisplay.clear(structure_place_text)
		$CancelStructure.visible = false
		await callback.call()
	set_winter_visible(false)
	$CancelStructure.visible = true
	$Shop.visible = false
	AlertDisplay.set_text(structure_place_text)

func _on_shop_button_pressed() -> void:
	$Shop.setup(deck, turn_manager)
	$Shop.visible = true
	set_winter_visible(false)

func _on_shop_on_shop_closed() -> void:
	$Shop.visible = false
	set_winter_visible(true)

func _on_shop_on_item_bought(item) -> void:
	deck.append(item)

func _on_shop_on_money_spent(amount) -> void:
	update()

func _on_shop_on_card_removed(card) -> void:
	deck.erase(card)
	$Shop.setup(deck, turn_manager)

# End Turn
func _on_end_turn_button_pressed() -> void:
	if turn_ending:
		return
	turn_ending = true
	Global.selected_card = null
	end_turn_button_pressed.emit()

func update_damage():
	$UI/DamagePanel.visible = turn_manager.blight_damage != 0
	for i in $UI/DamagePanel/BlightDamage.get_child_count():
		var img = $UI/DamagePanel/BlightDamage.get_child(i)
		if turn_manager.blight_damage > i:
			img.texture = load("res://assets/custom/Blight.png")
		else:
			img.texture = load("res://assets/custom/BlightEmpty.png")

func _on_next_year_button_pressed() -> void:
	on_next_year.emit()

func _on_farm_upgrade_button_pressed() -> void:
	if !$UpgradeShop.lock:
		$UpgradeShop.visible = true

func _on_upgrade_shop_on_upgrade(upgrade: Upgrade) -> void:
	apply_upgrade.emit(upgrade)

func select_card_to_remove():
	var select_card = SELECT_CARD.instantiate()
	select_card.tooltip = tooltip
	select_card.size = Constants.VIEWPORT_SIZE
	select_card.z_index = 2
	select_card.theme = load("res://assets/theme_large.tres")
	select_card.disable_cancel()
	select_card.select_callback = func(card_data):
		remove_child(select_card)
		deck.erase(card_data)
		$Shop.setup(deck, turn_manager)
	add_child(select_card)
	select_card.do_card_pick(deck, "Select a card to remove")

func select_card_to_copy():
	var select_card = SELECT_CARD.instantiate()
	select_card.tooltip = tooltip
	select_card.size = Constants.VIEWPORT_SIZE
	select_card.z_index = 2
	select_card.theme = load("res://assets/theme_large.tres")
	select_card.disable_cancel()
	select_card.select_callback = func(card_data):
		remove_child(select_card)
		deck.append(card_data)
		$Shop.setup(deck, turn_manager)
	add_child(select_card)
	select_card.do_card_pick(deck, "Select a card to copy")

func select_card_to_enhance(enhance: Enhance):
	var select_card = SELECT_CARD.instantiate()
	select_card.tooltip = tooltip
	select_card.size = Constants.VIEWPORT_SIZE
	select_card.z_index = 2
	select_card.theme = load("res://assets/theme_large.tres")
	select_card.disable_cancel()
	select_card.select_callback = func(card_data: CardData):
		remove_child(select_card)
		var new_card = card_data.apply_enhance(enhance)
		deck.erase(card_data)
		deck.append(new_card)
	add_child(select_card)
	select_card.do_enhance_pick(deck, enhance, "Select a card to enhance")

func next_year_allowed():
	var choice1 = $Shop/PanelContainer/ShopContainer/ChoiceOne/Stock
	var choice2 = $Shop/PanelContainer/ShopContainer/ChoiceTwo/Stock
	var upgradebutton = $Winter/FarmUpgradeButton
	var eventbutton = $Winter/EventPanel/VB/EventButton
	return (upgradebutton.disabled && eventbutton.disabled\
		&& !choice1.visible\
		&& !choice2.visible)\
		|| Settings.DEBUG

func _on_shop_on_blight_removed() -> void:
	turn_manager.blight_damage -= 1
	on_blight_removed.emit()
	update_damage()
	update()


func _on_farm_tiles_on_show_tile_preview(tile: Tile) -> void:
	$UI/TilePreview.setup(tile)
	$UI/TilePreview.visible = true
	var mouse_position = get_global_mouse_position()
	var offset = Vector2(30, 30)
	$UI/TilePreview/VBox.alignment = BoxContainer.ALIGNMENT_BEGIN
	if mouse_position.y > Constants.VIEWPORT_SIZE.y - Constants.CARD_SIZE.y * 2.5:
		offset = Vector2(30, -Constants.CARD_SIZE.y * 1.2)
		$UI/TilePreview/VBox.alignment = BoxContainer.ALIGNMENT_END
	$UI/TilePreview.position = get_global_mouse_position() + offset

func _on_farm_tiles_on_hide_tile_preview() -> void:
	$UI/TilePreview.visible = false

func is_winter():
	return $Winter.visible

func create_fortune_display():
	for child in $UI/FortuneDisplay.get_children():
		$UI/FortuneDisplay.remove_child(child)
	var fortune_count = 0
	for fortune: Fortune in $FortuneTeller.current_fortunes:
		var fortune_hover = FORTUNE_HOVER.instantiate()
		fortune_hover.position += Vector2(50, 0) * fortune_count
		$UI/FortuneDisplay.add_child(fortune_hover)
		fortune_hover.setup(fortune)
		fortune_count += 1
	for child in $PassiveDisplay.get_children():
		$PassiveDisplay.remove_child(child)
	if mage_fortune.name.length() > 0:
		var mage_fortune_hover = FORTUNE_HOVER.instantiate()
		$PassiveDisplay.add_child(mage_fortune_hover)
		mage_fortune_hover.setup(mage_fortune)
	if Global.ENERGY_FRAGMENTS > 0:
		var energy_fragments = FORTUNE_HOVER.instantiate()
		$PassiveDisplay.add_child(energy_fragments)
		energy_fragments.position += Vector2(50, 0) * ($PassiveDisplay.get_child_count() - 1)
		energy_fragments.setup_energy_fragments()
	if Global.SCROLL_FRAGMENTS > 0:
		var card_fragments = FORTUNE_HOVER.instantiate()
		$PassiveDisplay.add_child(card_fragments)
		card_fragments.position += Vector2(50, 0) * ($PassiveDisplay.get_child_count() - 1)
		card_fragments.setup_card_fragments()
	
func save_data(save_json):
	if save_json.state.winter:
		var winter = {}
		winter.upgrade_lock = $UpgradeShop.lock
		winter.event_disabled = $Winter/EventPanel/VB/EventButton.disabled
		winter.shop = shop.save_data()
		save_json.winter = winter
	save_json.fortunes = []
	for fortune: Fortune in get_fortunes():
		save_json.fortunes.append(fortune.save_data())
	
	save_json.events = {
		"current": GameEventDialog.current_event.save_data() if GameEventDialog.current_event != null else null,
		"completed": get_completed_events()
	}
	save_json.state.rerolls = $Shop.player_money
	save_json.state.mage = mage_fortune.save_data()

func load_data(save_json: Dictionary):
	if save_json.state.winter == true:
		$UI.visible = false
		$Winter.visible = true
		$UpgradeShop.lock = save_json.winter.upgrade_lock
		$Winter/EventPanel/VB/EventButton.disabled = save_json.winter.event_disabled
		GameEventDialog.current_event = load(save_json.events.current) if save_json.events.current != null else null
		GameEventDialog.update_interface()
		$Shop.load_data(save_json.winter.shop)
		$Tutorial.on_winter()
		$Tutorial.position.x = 1234
	$FortuneTeller.unregister_fortunes()
	$FortuneTeller.load_fortunes(save_json.fortunes)
	for event_path: String in save_json.events.completed:
		GameEventDialog.completed_events.append(load(event_path))
	mage_fortune = load(save_json.state.mage.path).new()
	mage_fortune.load_data(save_json.state.mage)
	create_fortune_display()
	$Shop.player_money = save_json.state.rerolls
	update()

func register_tooltips():
	tooltip.register_tooltip(energy_hbox, tr("ENERGY_TOOLTIP"))
	tooltip.register_tooltip(year_label, tr("YEAR_TOOLTIP").format({
		"current_year": turn_manager.year,
		"max_year": 10
	}));
	tooltip.register_tooltip($UI/Stats/VBox/TurnLabel, tr("WEEK_TOOLTIP").format({
		"current_week": turn_manager.week,
		"year_winter": 12
	}))
	tooltip.register_tooltip(cards_hbox, tr("CARDS_TOOLTIP"));
	tooltip.register_tooltip($UI/Deck/DeckPeek, tr("DECK_TOOLTIP").format({"deck_cards": deck.size()}))
	tooltip.register_tooltip($UI/EndTurnButton, tr("END_TURN_TOOLTIP"))
	tooltip.register_tooltip($UI/RitualPanel/RitualCounter, tr("RITUAL_TARGET_TOOLTIP").format({
		"count": turn_manager.ritual_counter,
		"path": "res://assets/custom/YellowMana.png"
	}))
	#tooltip.register_tooltip($UI/BlightPanel/VBox/BlightCounter, tr("BLIGHT_ATTACK_TOOLTIP").format({
		#"strength": turn_manager.target_blight,
		#"path": "res://assets/custom/PurpleMana.png"
	#}) if turn_manager.target_blight > 0 else tr("BLIGHT_NO_ATTACK_TOOLTIP").format({
		#"path": "res://assets/custom/PurpleMana.png"
	#}))
	
	tooltip.register_tooltip($Winter/NextYearButton, tr("TOOLTIP_NEXTYEAR"))
	tooltip.register_tooltip($Winter/FarmUpgradeButton, tr("TOOLTIP_UPGRADE"))
	tooltip.register_tooltip($UI/DamagePanel, "You have taken " + str(turn_manager.blight_damage) + " damage. Once you've taken 5 damage, you lose the game!")
func get_fortunes() -> Array[Fortune]:
	return $FortuneTeller.current_fortunes

func get_completed_events() -> Array[String]:
	var events: Array[String] = []
	for event in GameEventDialog.completed_events:
		events.append(event.save_data())
	return events
	
func display_cards(cards: Array[CardData], prompt: String):
	var select_card = SELECT_CARD.instantiate()
	select_card.tooltip = tooltip
	select_card.size = Constants.VIEWPORT_SIZE
	select_card.z_index = 2
	select_card.theme = load("res://assets/theme_large.tres")
	select_card.select_callback = func(card_data):
		pass
	add_child(select_card)
	$UI/Stats.visible = false
	select_card.select_cancelled.connect(func():
		remove_child(select_card)
		$UI/Stats.visible = true)
	select_card.do_card_display(cards, prompt)

func _on_deck_peek_pressed() -> void:
	display_cards(cards.get_deck_info(), "Deck")

func _on_discard_peek_pressed() -> void:
	display_cards(cards.get_discard_info(), "Discard Pile")

func _on_shop_view_deck() -> void:
	display_cards(deck, "Deck")

func before_end_year() -> void:
	AlertDisplay.set_text(end_year_alert_text)

func try_move_structure(tile: Tile):
	if !is_winter() or tile.structure == null or tile.structure.name == "River":
		return
	var structure = tile.structure.copy()
	tile.remove_structure()
	_on_shop_on_structure_place(structure, func():
		pass)
	$CancelStructure.visible = false

func reset_obelisk():
	$Obelisk.value = 0
	$Obelisk.max_value = turn_manager.ritual_counter


func _on_cancel_structure_pressed():
	AlertDisplay.clear(structure_place_text)
	$CancelStructure.visible = false
	set_winter_visible(true)
	$Shop.visible = true
	Global.selected_structure = null


func _on_farm_tiles_no_energy() -> void:
	if !$UI/EnergyDisplay.flashing:
		AlertDisplay.set_text(no_energy_text)
		await $UI/EnergyDisplay.no_energy()
		AlertDisplay.clear(no_energy_text)


func _on_end_screen_on_main_menu() -> void:
	on_main_menu.emit()


func _on_peek_button_mouse_entered() -> void:
	farm_preview_show.emit()

func _on_peek_button_mouse_exited() -> void:
	farm_preview_hide.emit()

func _on_menu_button_pressed() -> void:
	$PauseMenu.visible = true

func _on_pause_menu_go_to_main_menu() -> void:
	on_main_menu.emit()

func on_expand_farm() -> void:
	$Winter/ExpandFarm.display_dialogue()

func _on_expand_farm_on_close() -> void:
	after_farm_expanded.emit()

func set_mage_fortune(fortune):
	mage_fortune = fortune
	$UI/AttackPreview.mage_fortune = fortune
