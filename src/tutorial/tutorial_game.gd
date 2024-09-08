extends Playspace
class_name TutorialGame

func start_year():
	super.start_year()
	if turn_manager.year == 1:
		year_one()
	elif turn_manager.year == 2:
		year_two()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func end_year():
	super.end_year()
	if turn_manager.year == 1:
		user_interface.UpgradeButton.visible = false
		user_interface.FortuneTellerButton.visible = false
		user_interface.EventPanel.visible = false
		user_interface.shop.CHOICE_TWO.visible = false
		user_interface.shop.CHOICE_TWO_LABEL.visible = false
	elif turn_manager.year == 2:
		user_interface.shop.CHOICE_TWO.visible = true
		user_interface.shop.CHOICE_TWO_LABEL.visible = true
	elif turn_manager.year == 3:
		user_interface.EventPanel.visible = true
	elif turn_manager.year == 4:
		user_interface.UpgradeButton.visible = true
		user_interface.FortuneTellerButton.visible = true

func on_turn_end():
	super.on_turn_end()
	if turn_manager.year <= 2:
		turn_manager.week = 1

func year_one():
	for tile in farm.get_all_tiles():
		if tile.purple:
			tile.state = Enums.TileState.Inactive
			tile.update_display()
	user_interface.BlightPanel.visible = false
	user_interface.Stats.visible = false
	turn_manager.blight_pattern = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

func year_two():
	for tile in farm.get_all_tiles():
		tile.do_active_check()
	user_interface.BlightPanel.visible = true
