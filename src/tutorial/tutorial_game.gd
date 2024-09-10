extends Playspace
class_name TutorialGame

var ExplanationScene = preload("res://src/tutorial/explanation.tscn")

var farming_explanation
var shop_explanation
var winter_explanation

func start_year():
	if turn_manager.year == 0:
		Settings.TUTORIALS_ENABLED = false
		user_interface.EventPanel.visible = false
		Global.DIFFICULTY = -1
		Global.FINAL_YEAR = 4
		Constants.BASE_HAND_SIZE = 0
		deck = []
		deck.assign(StartupHelper.load_deck(StartupHelper.tutorial_deck))
		user_interface.setup(event_manager, turn_manager, deck, cards)
	elif turn_manager.year == 1:
		Constants.BASE_HAND_SIZE = 0
	super.start_year()
	match turn_manager.year:
		1:
			year_one()
		2:
			year_two()
		3:
			year_three()
		4:
			year_four()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save_game():
	pass

func end_year():
	await super.end_year()
	user_interface.EventButton.disabled = true
	if turn_manager.year == 1:
		year_one_end_year()
	elif turn_manager.year == 2:
		year_two_end_year()
	elif turn_manager.year == 3:
		year_three_end_year()
	elif turn_manager.year == 4:
		user_interface.UpgradeButton.visible = true
		

func on_turn_end():
	Constants.BASE_HAND_SIZE = 5
	await super.on_turn_end()
	match turn_manager.year:
		1:
			year_one_end_turn()
		2:
			year_two_end_turn()

func year_one():
	for tile in farm.get_all_tiles():
		if tile.purple:
			tile.state = Enums.TileState.Inactive
			tile.update_display()
	user_interface.BlightPanel.visible = false
	turn_manager.blight_pattern = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	#Hardcode turn 1
	var cards_copy = []
	cards_copy.assign(cards.deck_cards)
	for card in cards_copy:
		if cards.number_of_cards_in_hand >= 5:
			break
		if card.name == "Radish":
			cards.draw_specific_card(card)
			cards.deck_cards.erase(card)
		elif card.name == "Potato":
			cards.draw_specific_card(card)
			cards.deck_cards.erase(card)
	cards.reorganize_hand()
	user_interface.update()
	# Explanation: Year 1
	farming_explanation = ExplanationScene.instantiate()
	farming_explanation.set_text("Click on a [color=chartreuse]Seed Card[/color] (Radish, Potato) in your hand to select it. Then, click on an empty space on your farm to plant the seed there.\n\nEach card costs [color=orangered]Energy[/color] ([img]res://assets/custom/Energy.png[/img]) to play.\n\nWhen you're done your turn, click End Turn to go to the next week, and give your crops time to grow.")
	farming_explanation.position = Vector2(1250, 10)
	farming_explanation.set_exp_size(650, 375)
	user_interface.FarmingUi.add_child(farming_explanation)

func year_one_end_turn():
	match turn_manager.week:
		2:
			farming_explanation.set_text("Each plant takes [img]res://assets/custom/Time.png[/img] weeks to grow and generates [img]res://assets/custom/YellowMana16.png[/img] mana.\n\nHover your mouse over a tile on the farm to see details.\n\n[color=darkorange]Scythe cards[/color] will harvest mature plants, gaining " + Helper.mana_icon() + " if they are on a [color=gold]Yellow[/color] tile.\n\nGenerate 40 " + Helper.mana_icon() + " to complete the ritual and go to the next year.")

func year_one_end_year():
	user_interface.FortuneTellerButton.visible = false
	user_interface.shop.CHOICE_TWO.visible = false
	user_interface.shop.STOCK_TWO.visible = false
	user_interface.shop.CHOICE_TWO_LABEL.visible = false
	shop_explanation = ExplanationScene.instantiate()
	shop_explanation.set_text("[color=aquamarine]Shop[/color]: Choose one of the above cards to add to your deck. You can also skip this choice to get a reroll, which can be used later to refresh your options.\n\n[color=green]Seed cards (Green)[/color]: Plant a seed on your farm that generates " + Helper.mana_icon() + " after some amount of weeks.\n\n[color=red]Action Card (Red)[/color]: Perform special effects that can manipulate your plants or give you other benefits")
	shop_explanation.set_exp_size(1400, 250)
	shop_explanation.position = Vector2(270, 530)
	user_interface.shop.add_child(shop_explanation)
	winter_explanation = ExplanationScene.instantiate()
	winter_explanation.set_text("At the end of each year, go to the Shop to make your deck stronger by adding new cards.\n\nWhen you're ready, click the Next Year button to continue")
	winter_explanation.set_exp_size(500, 400)
	winter_explanation.position = Vector2(1250, 10)
	user_interface.WinterUi.add_child(winter_explanation)
	user_interface.WinterUi.move_child(winter_explanation, 0)
	user_interface.update()
	user_interface.FortuneTeller.current_fortunes.clear()
	user_interface.create_fortune_display()
	user_interface.shop.STOCK_ONE.get_child(0).set_data(load("res://src/cards/data/action/invigorate.tres"))
	user_interface.shop.STOCK_ONE.get_child(1).set_data(load("res://src/cards/data/seed/daylily.tres"))
	user_interface.shop.STOCK_ONE.get_child(2).set_data(load("res://src/cards/data/action/time_bubble.tres"))
	user_interface.shop.STOCK_ONE.get_child(3).set_data(load("res://src/cards/data/action/trusty_hoe.tres"))
	user_interface.shop.STOCK_ONE.get_child(4).set_data(load("res://src/cards/data/seed/mint.tres"))

func year_two():
	for tile in farm.get_all_tiles():
		tile.do_active_check()
	for tile in farm.get_all_tiles():
		if !tile.purple:
			tile.state = Enums.TileState.Inactive
			tile.update_display()
	user_interface.BlightPanel.visible = true
	turn_manager.blight_pattern = [0, 5, 0, 7, 0, 5, 0, 10, 0, 5, 0, 10, 10, 0, 10, 0]
	turn_manager.target_blight = 0
	turn_manager.next_turn_blight = 5
	farming_explanation.set_text("Plants harvested on [color=aqua]Blue tiles[/color] will not progress the ritual. Instead, they will protect you from the Blight's attacks.\n\nThe Blight will attack you next turn, as indicated by the 'Next turn: 5' display. Plant a Radish so that you can harvest it next turn to protect yourself.")
	# Hardcode turn 1
	var cards_copy = []
	cards_copy.assign(cards.deck_cards)
	for card in cards_copy:
		if cards.number_of_cards_in_hand >= 5:
			break
		if card.name == "Radish":
			cards.draw_specific_card(card)
			cards.deck_cards.erase(card)
		elif card.name == "Potato":
			cards.draw_specific_card(card)
			cards.deck_cards.erase(card)
	cards.reorganize_hand()
	user_interface.update()
	user_interface.FortuneTeller.current_fortunes.clear()
	user_interface.create_fortune_display()

func year_two_end_turn():
	match turn_manager.week:
		2:
			farming_explanation.set_text("Use a Scythe to harvest a plant on a [color=aqua]blue[/color] tile, which will generate " + Helper.blue_mana() + ". Generate at least 5 " + Helper.blue_mana() + " to protect yourself from the Blight this turn.\n\nBe careful! Excess " + Helper.blue_mana() + " will be lost at the end of the turn.")
		3:
			farming_explanation.set_text("Make sure to protect yourself by harvesting plants on [color=aqua]blue[/color] tiles whenever the Blight is attacking you.\n\nAt the same time, make sure to plant some plants on [color=gold]yellow[/color] tiles so you can complete the ritual.\n\nYou must complete the ritual before winter comes on Week 12, when your plants will stop growing.")
			for tile in farm.get_all_tiles():
				tile.do_active_check()

func year_two_end_year():
	user_interface.shop.CHOICE_TWO.visible = true
	user_interface.shop.CHOICE_TWO_LABEL.visible = true
	shop_explanation.set_text("Now you can also select one Structure or Enhance from the shop\n\n[color=lightcyan]Structure (Grey)[/color]: Occuppies one tile on your farm and grants a permanent bonus effect.\n\n[color=aqua]Enhance (blue)[/color]: Makes one card in your deck stronger")
	shop_explanation.position = Vector2(270, 875)
	user_interface.shop.STOCK_ONE.get_child(0).set_data(load("res://src/cards/data/action/leaf_ward.tres"))
	user_interface.shop.STOCK_ONE.get_child(1).set_data(load("res://src/cards/data/action/focus.tres"))
	user_interface.shop.STOCK_ONE.get_child(2).set_data(load("res://src/cards/data/seed/coffee.tres"))
	user_interface.shop.STOCK_ONE.get_child(3).set_data(load("res://src/cards/data/seed/cranberry.tres"))
	user_interface.shop.STOCK_ONE.get_child(4).set_data(load("res://src/cards/data/action/inspiration.tres"))
	user_interface.shop.STOCK_TWO.get_child(0).set_data(load("res://src/structure/data/sprinkler.tres"))
	user_interface.shop.STOCK_TWO.get_child(1).set_data(load("res://src/enhance/data/discount.tres"))
	user_interface.shop.STOCK_TWO.get_child(2).set_data(load("res://src/enhance/data/growspeed.tres"))
	user_interface.FortuneTeller.current_fortunes.clear()
	user_interface.FortuneTeller.current_fortunes.append(load("res://src/fortune/data/daylily_fortune.gd").new())
	user_interface.FortuneTeller.current_fortunes.append(load("res://src/fortune/data/blightroot_once.gd").new())
	user_interface.create_fortune_display()

func year_three():
	turn_manager.blight_pattern = [0, 0, 10, 0, 10, 5, 0, 15, 10, 0, 10, 0, 10, 10, 0, 10]
	farming_explanation.set_exp_size(650, 350)
	farming_explanation.set_text("Each year, various positive and negative Fortunes will help or hinder your progress.\n\nHover over the icons underneath this text to see the details of this year's Fortunes.\n\nMake sure to adapt your strategy in order to complete this year's Ritual safely!")

func year_three_end_year():
	user_interface.FortuneTellerButton.visible = true
	winter_explanation.visible = false
	winter_explanation.set_text("At the end of the year, an Event will occur that will give you something useful. Click on the Event button.")
	winter_explanation.set_exp_size(500, 300)
	user_interface.shop.remove_child(shop_explanation)
	user_interface.FortuneTeller.current_fortunes.clear()
	user_interface.FortuneTeller.current_fortunes.append(load("res://src/fortune/data/wildflowers.gd").new())
	user_interface.FortuneTeller.current_fortunes.append(load("res://src/fortune/data/weeds_on_farm.gd").new())
	user_interface.create_fortune_display()
	user_interface.shop.STOCK_TWO.get_child(0).set_data(load("res://src/structure/data/harvester.tres"))
	user_interface.shop.STOCK_TWO.get_child(1).set_data(load("res://src/enhance/data/regrow.tres"))
	user_interface.shop.STOCK_TWO.get_child(2).set_data(load("res://src/enhance/data/plus1yield.tres"))

func year_four():
	turn_manager.blight_pattern = [0, 0, 10, 0, 10, 5, 0, 15, 10, 0, 10, 0, 10, 10, 0, 10]
	farming_explanation.visible = false
