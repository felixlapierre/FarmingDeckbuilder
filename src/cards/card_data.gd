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
@export var strength_increment: float = 1.0
@export var size_increment: int = 1
@export var texture: Texture2D
@export var seed_texture: int
@export var texture_icon_offset: int = 16
@export var targets: Array[String]
@export var effects: Array[Effect]
@export var enhances: Array[String]
@export var strength: float

func _init(p_type = "CARD", p_name = "PlaceholderCardName", p_rarity = "common", p_cost = 1, p_yld = 1,\
	p_time = 1, p_size = 1, p_text = "", p_texture = null, p_seed_texture = 1, p_targets = [], p_effects = [],\
	p_strength_increment = 1.0, p_size_increment = 1, p_text_icon_offset = 16, p_enhances = [], p_strength = 0):
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
		enhances.assign(p_enhances)
		strength_increment = p_strength_increment
		size_increment = p_size_increment
		texture_icon_offset = p_text_icon_offset
		strength = p_strength

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
	for enhance in other.enhances:
		enhances.append(enhance)
	strength_increment = other.strength_increment
	size_increment = other.size_increment
	texture_icon_offset = other.texture_icon_offset
	strength = other.strength

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
		"Burn":
			n_card.effects.append(load("res://src/effect/data/obliviate.tres"))
		"Frozen":
			n_card.effects.append(load("res://src/effect/data/remembrance.tres"))
		"RemoveObliviate":
			n_card.effects.erase(load("res://src/effect/data/obliviate.tres"))
		"Strength":
			n_card.apply_strength(enhance)
		"Size":
			n_card.size += enhance.strength * size_increment
		"Springbound":
			n_card.effects.append(load("res://src/effect/data/springbound.tres"))
		"Regrow":
			for effect in n_card.effects:
				if effect.name == "plant":
					effect.strength += enhance.strength
					n_card.enhances.append(enhance.name)
					return n_card
			n_card.effects.append(load("res://src/effect/data/regrow_3.tres"))
			n_card.time += 1
	n_card.enhances.append(enhance.name)
	return n_card

func apply_strength(enhance: Enhance):
	if can_strengthen_custom_effect():
		strength += enhance.strength * strength_increment
	for effect in effects:
		if effect.strength > 0.0:
			effect.strength += enhance.strength * strength_increment
			break
		elif effect.strength < 0.0:
			effect.strength -= enhance.strength * strength_increment
			break

func get_description() -> String:
	var descr = text
	for effect in effects:
		var effect_text = effect.get_short_description(self)
		if effect_text.length() > 0:
			if descr.length() > 0:
				descr += ". "
			descr += effect_text
	return descr.replace("{STRENGTH}", str(strength))

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, tile: Tile):
	pass

func unregister_events(event_manager: EventManager):
	pass

func register_seed_events(event_manager: EventManager, tile: Tile):
	pass

func unregister_seed_events(event_manager: EventManager):
	pass

func get_yield(tile: Tile) -> EventArgs.HarvestArgs:
	var yld = tile.current_yield if get_effect("corrupted") == null else -tile.current_yield
	return EventArgs.HarvestArgs.new(yld, tile.purple, false)

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
			return effect.save_data()),
		"strength_increment": strength_increment,
		"size_increment": size_increment,
		"texture_icon_offset": texture_icon_offset,
		"enhances": enhances,
		"strength": strength
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
	enhances.assign(data.enhances)
	strength_increment = data.strength_increment
	size_increment = data.size_increment
	texture_icon_offset = data.texture_icon_offset
	strength = data.strength
	return self

# Override with true in subclasses that use the strength member variable
func can_strengthen_custom_effect():
	return false

func preview_yield(tile: Tile):
	var yld_purple = 0.0
	var yld_yellow = 0.0
	var defer = get_effect("harvest_delay") != null
	if (get_effect("harvest") != null\
		or get_effect("harvest_delay") != null)\
		and tile.card_can_target(self):
		var harvest: EventArgs.HarvestArgs = tile.preview_harvest()
		if harvest.purple:
			yld_purple += harvest.yld
		else:
			yld_yellow += harvest.yld
		defer = defer or harvest.delay
	var increase_yield = get_effect("increase_yield")
	if increase_yield != null:
		yld_purple *= 1.0 + increase_yield.strength
		yld_yellow *= 1.0 + increase_yield.strength
	return {
		"purple": yld_purple,
		"yellow": yld_yellow,
		"defer": defer
	}
