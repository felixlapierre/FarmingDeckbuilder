extends AttackPattern
class_name SimpleAttack

var fortunes_once = []
var fortunes_every_turn = []
var fortunes_even = []
var fortunes_odd = []
var fortunes_random = []
var fortunes_at = []

func save_data():
	var data = super.save_data()
	data.path = get_script().get_path()
	data.fortunes_once = []
	data.fortunes_every_turn = []
	data.fortunes_even = []
	data.fortunes_odd = []
	data.fortunes_random = []
	data.fortunes_at = []
	for fortune in fortunes_once:
		data.fortunes_once.append(fortune.save_data())
	for fortune in fortunes_every_turn:
		data.fortunes_every_turn.append(fortune.save_data())
	for fortune in fortunes_even:
		data.fortunes_even.append(fortune.save_data())
	for fortune in fortunes_odd:
		data.fortunes_odd.append(fortune.save_data())
	for fortune in fortunes_random:
		data.fortunes_random.append(fortune.save_data())
	for entry in fortunes_at:
		data.fortunes_at.append({
			"week": entry.week,
			"fortune": entry.fortune.save_data()
		})
	return data

func load_data(data):
	super.load_data(data)
	for fortune_data in data.fortunes_once:
		fortunes_once.append(load_fortune(fortune_data))
	for fortune_data in data.fortunes_every_turn:
		fortunes_every_turn.append(load_fortune(fortune_data))
	for fortune_data in data.fortunes_even:
		fortunes_even.append(load_fortune(fortune_data))
	for fortune_data in data.fortunes_odd:
		fortunes_odd.append(load_fortune(fortune_data))
	for fortune_data in data.fortunes_random:
		fortunes_random.append(load_fortune(fortune_data))
	for entry_data in data.fortunes_at:
		var entry = {}
		entry.week = entry_data.week
		entry.fortune = load_fortune(entry_data.fortune)
		fortunes_at.append(entry)
	fortunes_random.shuffle()

func load_fortune(data):
	var fortune = load(data.path).new()
	fortune.load_data(data)
	return fortune

func get_fortunes_at_week(week: int) -> Array[Fortune]:
	var result: Array[Fortune] = []
	if week == 1:
		result.append_array(fortunes_once)
	result.append_array(fortunes_every_turn)
	if week % 2 == 0:
		result.append_array(fortunes_even)
	else:
		result.append_array(fortunes_odd)
	if fortunes_random.size() > 0:
		var rand_index = week % (fortunes_random.size())
		result.append(fortunes_random[rand_index])
	for entry in fortunes_at:
		if entry.week == week:
			result.append(entry.fortune)
	return result

func get_all_fortunes_display():
	var result = []
	result.append_array(fortunes_once)
	result.append_array(fortunes_every_turn)
	result.append_array(fortunes_even)
	result.append_array(fortunes_odd)
	result.append_array(fortunes_random)
	for entry in fortunes_at:
		result.append(entry.fortune)
	return result
