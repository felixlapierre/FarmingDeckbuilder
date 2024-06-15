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

func copy():
	var n_targets = []
	for target in targets:
		n_targets.append(target)
	var n_effects = []
	for effect in effects:
		n_effects.append(effect.copy())
	
	return CardData.new(type, name, rarity, cost, yld, time, size, text, texture, seed_texture, n_targets, n_effects)

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
	return n_card

func apply_strength(enhance: Enhance):
	for effect in effects:
		if effect.strength != 0.0:
			effect.strength += enhance.strength
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
