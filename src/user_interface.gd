extends Node2D

class_name UserInterface

signal apply_upgrade
signal end_turn_button_pressed
signal on_skip
signal on_next_year
signal on_blight_removed

@export var turn_manager: TurnManager

var shop_structure_place_callback
var deck: Array[CardData]
var turn_ending = false

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in Constants.MAX_BLIGHT:
		var sprite = TextureRect.new()
		sprite.texture = load("res://assets/custom/BlightEmpty.png")
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		$UI/BlightPanel/VBox/BlightDamage.add_child(sprite)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(p_event_manager: EventManager, p_turn_manager: TurnManager, p_deck: Array[CardData]):
	$FortuneTeller.setup(p_event_manager)
	turn_manager = p_turn_manager
	deck = p_deck
	$GameEventDialog.setup(deck, turn_manager)
	$Shop.setup(deck, turn_manager)
	register_tooltips()

# Start and end year
func end_year():
	$UI.visible = false
	$Winter.visible = true
	$UpgradeShop.lock = false
	$Winter/EventButton.disabled = false
	$GameEventDialog.generate_random_event()
	$Shop.fill_shop()
	$FortuneTeller.unregister_fortunes()
	$FortuneTeller.create_fortunes()
	create_fortune_display()
	update()
	
func start_year():
	$FortuneTeller.register_fortunes()
	$UI.visible = true
	$Winter.visible = false
	update()

# Update UI display
func update():
	$UI/Stats/VBox/YearLabel.text = "Year: " + str(turn_manager.year) + " / 10"
	$UI/Stats/VBox/TurnLabel.text = "Week: " + str(turn_manager.week) + " / 12"
	$UI/Stats/VBox/EnergyHbox/EnergyLabel.text = "Energy: " + str(turn_manager.energy) + " / " + str(Constants.MAX_ENERGY + int(float(Global.ENERGY_FRAGMENTS) / 3))
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
		
	$UI/BlightPanel/VBox/BlightCounter/Label.text = str(turn_manager.purple_mana)\
		 + " / " + str(turn_manager.target_blight)\
		 + " <-- " + str(turn_manager.next_turn_blight)
	$UI/RitualPanel/RitualCounter/Label.text = str(turn_manager.ritual_counter)
	$Shop.update_labels()
	$Winter/FarmUpgradeButton.disabled = $UpgradeShop.lock or ![4, 7, 10].has(turn_manager.year)
	# Temporarily disable this QOL for testing
	$Winter/NextYearButton.disabled = !next_year_allowed()
	
	register_tooltips()
	


# Fortune Teller
func _on_fortune_teller_button_pressed() -> void:
	$FortuneTeller.visible = true

func _on_fortune_teller_on_close() -> void:
	$FortuneTeller.visible = false

# Event
func _on_event_button_pressed() -> void:
	$GameEventDialog.visible = true
	
func _on_game_event_dialog_on_upgrades_selected(upgrades: Array[Upgrade]) -> void:
	for upgrade in upgrades:
		if upgrade.type == Upgrade.UpgradeType.AddCommonCard or upgrade.type == Upgrade.UpgradeType.AddRareCard:
			var cards = cards_database.get_random_cards("common" if upgrade.type == Upgrade.UpgradeType.AddCommonCard else "rare", 3)
			var pick_option_ui = PickOption.instantiate()
			self.add_child(pick_option_ui)
			var prompt = "Pick a card to add to your deck"
			pick_option_ui.setup(prompt, cards, func(selected):
				var add_card_upgrade = Upgrade.new()
				add_card_upgrade.type = Upgrade.UpgradeType.AddSpecificCard
				add_card_upgrade.card = selected.card_info
				apply_upgrade.emit(add_card_upgrade)
				self.remove_child(pick_option_ui), func():
					self.remove_child(pick_option_ui))
		elif upgrade.type == Upgrade.UpgradeType.AddEnhance\
			or upgrade.type == Upgrade.UpgradeType.AddEnhanceToRandom\
			or upgrade.type == Upgrade.UpgradeType.AddEnhanceToAll:
			var enhances = cards_database.get_random_enhance("", 3)
			var pick_option_ui = PickOption.instantiate()
			self.add_child(pick_option_ui)
			var prompt = "Pick an enhance to apply"
			pick_option_ui.setup(prompt, enhances, func(selected):
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
				self.remove_child(pick_option_ui),
				func():
					self.remove_child(pick_option_ui))
		elif upgrade.type == Upgrade.UpgradeType.AddStructure:
			var structures = cards_database.get_random_structures(3)
			var pick_option_ui = PickOption.instantiate()
			self.add_child(pick_option_ui)
			var prompt = "Pick a structure to add to your farm"
			pick_option_ui.setup(prompt, structures, func(selected):
				self.remove_child(pick_option_ui)
				_on_shop_on_structure_place(selected, func():
					pass), func():
						self.remove_child(pick_option_ui))
		else:
			apply_upgrade.emit(upgrade)
	$GameEventDialog.visible = false
	$Winter/EventButton.disabled = true
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
func _on_farm_tiles_on_preview_yield(yellow, purple) -> void:
	$UI/Preview.visible = yellow + purple > 0
	$UI/Preview/Panel/HBox/PreviewYellow.text = "+" + str(yellow)
	$UI/Preview/Panel/HBox/PreviewPurple.text = "+" + str(purple)
	
# Winter
func set_winter_visible(visible):
	$Winter.visible = visible

func set_ui_visible(visible):
	$Winter/ShopButton.visible = visible
	$UI/Deck.visible = visible
	$UI/EndTurnButton.visible = visible
	$Shop.visible = visible
	$UI/BlightPanel/VBox/BlightCounter.visible = visible
	$UI/RitualPanel/RitualCounter.visible = visible

# Shop
func _on_shop_on_structure_place(structure, callback) -> void:
	Global.selected_structure = structure
	Global.selected_card = null
	shop_structure_place_callback = callback
	set_winter_visible(false)
	$Shop.visible = false

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
	$UI/BlightPanel/VBox/BlightDamage.visible = turn_manager.blight_damage != 0
	for i in $UI/BlightPanel/VBox/BlightDamage.get_child_count():
		var img = $UI/BlightPanel/VBox/BlightDamage.get_child(i)
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
	var eventbutton = $Winter/EventButton
	return upgradebutton.disabled && eventbutton.disabled\
		&& !choice1.visible\
		&& !choice2.visible


func _on_shop_on_blight_removed() -> void:
	turn_manager.blight_damage -= 1
	on_blight_removed.emit()
	update_damage()
	update()


func _on_farm_tiles_on_show_tile_preview(tile: Tile) -> void:
	$UI/TilePreview.setup(tile)
	$UI/TilePreview.visible = true

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
	
func save_data() -> Dictionary:
	var winter = {}
	winter.upgrade_lock = $UpgradeShop.lock
	winter.event_disabled = $Winter/EventButton.disabled
	winter.shop = shop.save_data()
	return winter

func load_data(save_json: Dictionary):
	if save_json.state.winter == true:
		$UI.visible = false
		$Winter.visible = true
		$UpgradeShop.lock = save_json.winter.upgrade_lock
		$Winter/EventButton.disabled = save_json.winter.event_disabled
		$GameEventDialog.generate_random_event()
		$Shop.load_data(save_json.winter.shop)
	$FortuneTeller.unregister_fortunes()
	$FortuneTeller.load_fortunes(save_json.fortunes)
	create_fortune_display()
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
	tooltip.register_tooltip($UI/Deck/DeckDraw, tr("DECK_TOOLTIP").format({"deck_cards": deck.size()}))
	tooltip.register_tooltip($UI/EndTurnButton, tr("END_TURN_TOOLTIP"))
	tooltip.register_tooltip($UI/RitualPanel/RitualCounter, tr("RITUAL_TARGET_TOOLTIP").format({
		"count": turn_manager.ritual_counter,
		"path": "res://assets/custom/YellowMana.png"
	}))
	tooltip.register_tooltip($UI/BlightPanel/VBox/BlightCounter, tr("BLIGHT_ATTACK_TOOLTIP").format({
		"strength": turn_manager.target_blight,
		"path": "res://assets/custom/PurpleMana.png"
	}) if turn_manager.target_blight > 0 else tr("BLIGHT_NO_ATTACK_TOOLTIP").format({
		"path": "res://assets/custom/PurpleMana.png"
	}))
	
func get_fortunes() -> Array[Fortune]:
	return $FortuneTeller.current_fortunes
