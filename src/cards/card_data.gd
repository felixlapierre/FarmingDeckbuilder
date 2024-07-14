extends Resource

class_name CardData

const CLASS_NAME = "CardData"

@export var type: String
@export var name: String
@export var rarity: String
@export var cost: int
@export var yld: int
@export var time: int
@export var size: int
@export var text: String
@export var texture: Texture2D
@export var seed_texture: int
@export var targets: Array[String]
@export var effects: Array[Effect]

func _init(p_type = "CARD", p_name = "PlaceholderCardName", p_rarity = "common", p_cost = 1, p_yld = 1,\
	p_time = 1, p_size = 1, p_text = "", p_texture = null, p_seed_texture = 1, p_targets = [], p_effects = []):
		type = p_type
		name = p_name
		rarity = p_rarity
		cost = p_cost
		yld = p_yld
		time = p_time
		size = p_size
		text = p_text
		texture = p_texture
		seed_texture = p_seed_texture
		targets.assign(p_targets)
		effects.assign(p_effects)

func get_effect(effect_name):
	for effect in effects:
		if effect.name == effect_name:
			return effect
	return null

func copy() -> CardData:
	var new = CardData.new()
	new.assign(self)
	return new

func assign(other: CardData) -> void:
	type = other.type
	name = other.name
	rarity = other.rarity
	cost = other.cost
	yld = other.yld
	time = other.time
	size = other.size
	text = other.text
	texture = other.texture
	seed_texture = other.seed_texture
	for target in other.targets:
		targets.append(target)
	for effect in other.effects:
		effects.append(effect.copy())

func apply_enhance(enhance: Enhance):
	var n_card = copy()
	match enhance.name:
		"Discount":
			n_card.cost = cost - int(enhance.strength)
		"GrowSpeed":
			n_card.time -= int(enhance.strength) if time > int(enhance.strength) else 0
			if n_card.time < 1:
				n_card.time = 1
		"FlatYield":
			n_card.yld += int(enhance.strength)
		"SpreadGrow":
			n_card.effects.append(load("res://src/effect/data/spread_on_grow.tres"))
		"SpreadHarvest":
			n_card.effects.append(load("res://src/effect/data/spread_on_harvest.tres"))
		"Obliviate":
			n_card.effects.append(load("res://src/effect/data/obliviate.tres"))
		"Remembrance":
			n_card.effects.append(load("res://src/effect/data/remembrance.tres"))
		"RemoveObliviate":
			n_card.effects.erase(load("res://src/effect/data/obliviate.tres"))
		"Strength":
			n_card.apply_strength(enhance)
		"Size":
			n_card.size += enhance.strength
		"Springbound":
			n_card.effects.append(load("res://src/effect/data/springbound.tres"))
	return n_card

func apply_strength(enhance: Enhance):
	for effect in effects:
		if effect.strength > 0.0:
			effect.strength += enhance.strength
			break
		elif effect.strength < 0.0:
			effect.strength -= enhance.strength
			break

func get_description() -> String:
	var descr = text
	for effect in effects:
		var effect_text = effect.get_short_description()
		if effect_text.length() > 0:
			if descr.length() > 0:
				descr += ". "
			descr += effect_text
	return descr

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, tile: Tile):
	pass

func unregister_events(event_manager: EventManager):
	pass

func register_seed_events(event_manager: EventManager, tile: Tile):
	pass

func unregister_seed_events(event_manager: EventManager):
	pass

func save_data() -> Dictionary:
	var save_dict = {
		"path": get_script().get_path(),
		"type": type,
		"name": name,
		"rarity": rarity,
		"cost": cost,
		"yld": yld,
		"time": time,
		"size": size,
		"text": text,
		"texture": texture.resource_path if texture != null else null,
		"seed_texture": seed_texture,
		"targets": targets,
		"effects": effects.map(func(effect):
			return effect.save_data())
	}
	return save_dict

func load_data(data) -> CardData:
	type = data.type
	name = data.name
	rarity = data.rarity
	cost = data.cost
	yld = data.yld
	time = data.time
	size = data.size
	text = data.text
	texture = load(data.texture) if data.texture != null else null
	seed_texture = data.seed_texture
	targets.assign(data.targets)
	effects.assign(data.effects.map(func(effect):
		var eff = load(effect.path).new()
		eff.load_data(effect)
		return eff))
	return self
