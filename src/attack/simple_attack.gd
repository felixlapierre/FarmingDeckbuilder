extends AttackPattern
class_name SimpleAttack

var fortunes_once = []
var fortunes_every_turn = []

func save_data():
	var data = super.save_data()
	data.path = get_script().get_path()
	data.fortunes_once = []
	for fortune in fortunes_once:
		data.fortunes_once.append(fortune.save_data())
	data.fortunes_every_turn = []
	for fortune in fortunes_every_turn:
		data.fortunes_every_turn.append(fortune.save_data())
	return data

func load_data(data):
	super.load_data(data)
	for fortune_data in data.fortunes_once:
		var fortune = load(fortune_data.path).new()
		fortune.load_data(fortune_data)
		fortunes_once.append(fortune)
	for fortune_data in data.fortunes_every_turn:
		var fortune = load(fortune_data.path).new()
		fortune.load_data(fortune_data)
		fortunes_every_turn.append(fortune)

func get_fortunes_at_week(week: int) -> Array[Fortune]:
	var result: Array[Fortune] = []
	if week == 1:
		result.append_array(fortunes_once)
	result.append_array(fortunes_every_turn)
	return result

func get_all_fortunes_display():
	var result = []
	result.append_array(fortunes_once)
	result.append_array(fortunes_every_turn)
	return result
