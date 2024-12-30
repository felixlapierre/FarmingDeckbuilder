extends Node
class_name Attack

static func WeedsOnce(strength: int):
	return SimpleAttackBuilder.new().fortune_once(AddWeeds.new(strength)).build()

static func WeedsEvery(strength: int, turns: int):
	return SimpleAttackBuilder.new().fortune_every(AddWeeds.new(strength), turns).build()

static func FillWeedsOnce():
	return SimpleAttackBuilder.new().fortune_once(WeedsEntireFarm.new()).build()

static func FillWeedsEvery(turns: int):
	return SimpleAttackBuilder.new().fortune_every(WeedsEntireFarm.new(), turns).build()

static func WeedsCardEvery(strength: int):
	return SimpleAttackBuilder.new().fortune_every_turn(WeedsEveryCard.new(strength)).build()

static func BlightrootOnce(strength: int):
	return SimpleAttackBuilder.new().fortune_once(AddBlightroot.new(strength)).build()

static func BlightrootEvery(strength: int, turns: int):
	return SimpleAttackBuilder.new().fortune_every(AddBlightroot.new(strength), turns).build()
	
static func DeathcapOnce(strength: int):
	return SimpleAttackBuilder.new().fortune_once(AddDeathcap.new(strength)).build()

static func DeathcapEvery(strength: int, turns: int):
	return SimpleAttackBuilder.new().fortune_every(AddDeathcap.new(strength), turns).build()

static func CorpseFlowerOnce(strength: int):
	return SimpleAttackBuilder.new().fortune_once(AddCorpseFlower.new(strength)).build()

static func CorpseFlowerEvery(strength: int, turns: int):
	return SimpleAttackBuilder.new().fortune_every(AddCorpseFlower.new(strength), turns).build()

