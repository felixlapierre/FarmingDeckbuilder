extends Node
class_name AttacksAdvanced

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_advanced_attack_year(year: int):
	pass
		#10:
			#return pick_random([SimpleAttackBuilder.new().fortune_odd(DestroyRow).fortune_even(DestroyCol).build(),\
				#SimpleAttackBuilder.new().fortune_every_turn(AddCorpseFlower).build()])
		#11:
			#return SimpleAttackBuilder.new()\
				#.fortune_every_turn(pick_random([DestroyRow, DestroyCol, AddCorpseFlower]))\
				#.fortune_even(IncreaseRitual10)\
				#.build()
		#12:
			#return SimpleAttackBuilder.new()\
				#.fortune_every_turn(pick_random([DestroyRow, DestroyCol, AddCorpseFlower]))\
				#.fortune_even(pick_random([IncreaseRitual10, EndTurnRotate.new()]))\
				#.fortune_odd(Counter)\
				#.build()
		#13:
			#return SimpleAttackBuilder.new()\
				#.fortune_every_turn(pick_random([DestroyRow, DestroyCol, AddCorpseFlower]))\
				#.fortune_even(IncreaseRitual10)\
				#.fortune_odd(Counter)\
				#.fortune_once(StartWithWeeds)\
				#.fortune_at(WeedsEntireFarm, 3)\
				#.build()
		#_:
			#return SimpleAttackBuilder.new()\
				#.fortune_every_turn(pick_random([DestroyRow, DestroyCol, AddCorpseFlower]))\
				#.fortune_every_turn(IncreaseRitual10)\
				#.fortune_odd(pick_random([Counter, ObliviateRightmost, EndTurnRotate.new()]))\
				#.fortune_once(pick_random([StartWithWeeds, BlightrootTurnStart]))\
				#.fortune_at(WeedsEntireFarm, 3)\
				#.build()

