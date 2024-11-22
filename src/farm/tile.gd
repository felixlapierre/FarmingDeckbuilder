extends MarginContainer
class_name Tile

var state = Enums.TileState.Empty # Store the state of the farm tile
var grid_location: Vector2
var TILE_SIZE = Vector2(56, 56);
var FARM_DIMENSIONS = Vector2(6, 6);
var objects_image = "res://assets/1616tinygarden/objects.png"

var seed = null # To contain information about the seed being grown here
var structure: Structure = null

var seed_base_yield = 0.0
var seed_grow_time = 0.0
var current_yield = 0.0
var current_grow_progress = 0.0
var irrigated = false
var IRRIGATED_MULTIPLIER = 0.4
var purple = false
var structure_rotate = 0
var blight_targeted = false
var destroy_targeted = false

var destroyed = false
var blighted = false
var protected = false

signal tile_hovered
signal on_event
signal on_yield_gained

var event_manager: EventManager

var COLOR_NONE = Color8(255, 255, 255)
var COLOR_IRRIGATE = Color8(136, 183, 252)
var COLOR_DESTROYED = Color8(45, 45, 45)
var COLOR_BLIGHTED = Color8(110, 41, 110)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.register_click_callback(self)
	do_active_check()

func do_active_check():
	if grid_location.x < Global.FARM_TOPLEFT.x\
		or grid_location.x > Global.FARM_BOTRIGHT.x\
		or grid_location.y < Global.FARM_TOPLEFT.y\
		or grid_location.y > Global.FARM_BOTRIGHT.y:
		state = Enums.TileState.Inactive
	elif state == Enums.TileState.Inactive:
		state = Enums.TileState.Empty
	update_display()

func update_display():
	update_purple_overlay()
	if state == Enums.TileState.Inactive:
		$PurpleOverlay.visible = false
		$Farmland.visible = false
		$TileButton.visible = false
		return
	$PurpleOverlay.visible = purple
	$Farmland.visible = true
	$TileButton.visible = true
	if grid_location.x == Global.FARM_TOPLEFT.x:
		$Farmland.region_rect.position.x = 0
	elif grid_location.x == Global.FARM_BOTRIGHT.x:
		$Farmland.region_rect.position.x = 48
	else:
		$Farmland.region_rect.position.x = 16

	if grid_location.y == Global.FARM_TOPLEFT.y:
		$Farmland.region_rect.position.y = 0
	elif grid_location.y == Global.FARM_BOTRIGHT.y:
		$Farmland.region_rect.position.y = 48
	else:
		$Farmland.region_rect.position.y = 16

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_tile_button_mouse_entered() -> void:
	if !Settings.CLICK_MODE:
		tile_hovered.emit(self)

func _on_tile_button_mouse_exited() -> void:
	if !Settings.CLICK_MODE:
		tile_hovered.emit(null)

func _on_tile_button_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and !Settings.CLICK_MODE:
		Global.MOBILE = true
		Global.pressed = event.pressed
		if event.pressed:
			tile_hovered.emit(self)
		else:
			tile_hovered.emit(null)
			if Global.pressed_time <= 0.5:
				$"../../".use_card(grid_location)
	elif event.is_action_pressed("leftclick") and Settings.CLICK_MODE:
		if $"../../".hovered_tile == self:
			$"../../".use_card(grid_location)
		else:
			tile_hovered.emit(self)
	elif event.is_action_pressed("leftclick") and !Global.MOBILE:
		$"../../".use_card(grid_location)

func on_other_clicked():
	if Settings.CLICK_MODE:
		tile_hovered.emit(null)

func plant_seed_animate(planted_seed) -> Array[Effect]:
	var effects = plant_seed(planted_seed)
	var tween = get_tree().create_tween()
	tween.tween_property($PlantSprite, "scale", $PlantSprite.scale, 0.1);
	$PlantSprite.scale = Vector2(0, 0)
	return effects

func plant_seed(planted_seed) -> Array[Effect]:
	var effects: Array[Effect] = []
	if state == Enums.TileState.Empty:
		seed = planted_seed
		seed.register_seed_events(event_manager, self)
		effects.append_array(get_effects("plant"))
		seed_grow_time = float(seed.time)
		seed_base_yield = float(seed.yld)
		current_grow_progress = 0.0
		current_yield = 0.0
		state = Enums.TileState.Growing
		if seed_grow_time == 0:
			state = Enums.TileState.Mature
			current_yield = seed_base_yield
		$PlantSprite.visible = true
		if seed.texture != null:
			$PlantSprite.texture = seed.texture
		else:
			$PlantSprite.texture = load(objects_image)
		$PlantSprite.region_enabled = true
		update_plant_sprite()
	event_manager.notify_specific_args(EventManager.EventType.OnPlantPlanted, EventArgs.SpecificArgs.new(self))
	return effects
	
func grow_one_week() -> Array[Effect]:
	var effects: Array[Effect] = []
	if state == Enums.TileState.Growing:
		effects.append_array(get_effects("grow"))
		current_grow_progress += 1.0
		var multiplier = 1.0
		if irrigated:
			multiplier += IRRIGATED_MULTIPLIER
			var absorb = seed.get_effect("absorb")
			if absorb != null:
				multiplier += IRRIGATED_MULTIPLIER * absorb.strength
		current_yield += seed_base_yield / seed_grow_time * multiplier
		update_plant_sprite()
		grow_animation()
		if current_grow_progress == seed_grow_time:
			state = Enums.TileState.Mature
	event_manager.notify_specific_args(EventManager.EventType.OnPlantGrow, EventArgs.SpecificArgs.new(self))
	return effects

func grow_animation():
	var tween = get_tree().create_tween()
	tween.tween_property($PlantSprite, "scale", $PlantSprite.scale * Vector2(0.8, 1.2), 0.1)
	tween.tween_property($PlantSprite, "scale", $PlantSprite.scale * Vector2(1, 1), 0.1)

func update_plant_sprite():
	if seed.texture == null:
		var stage = 3 if seed_grow_time == 0 else int(current_grow_progress / seed_grow_time * 3)
		var y
		var h
		match stage:
			0:
				y = 32
				h = 16
			1:
				h = 16
				y = 48
			2:
				y = 64
				h = 32
			3:
				y = 96
				h = 32
			
		$PlantSprite.set_region_rect(Rect2(seed.seed_texture * 16, y, 16, h))
		$PlantSprite.offset = Vector2(0, -8 if h == 16 else -14)
		$PlantSprite.scale = Vector2(1, 1)
	else:
		var resolution = seed.texture.get_height() / 2
		var max_stage: int = seed.texture.get_width() / resolution - 1
		var current_stage = int(current_grow_progress / seed_grow_time * max_stage)
		var x = resolution * current_stage
		$PlantSprite.set_region_rect(Rect2(x, 0, resolution, resolution*2))
		$PlantSprite.offset = Vector2(0, -resolution)
		$PlantSprite.scale = Vector2(16.0 / resolution, 16.0 / resolution)

func harvest(delay) -> Array[Effect]:
	var effects: Array[Effect] = []
	var harvest_args = notify_harvest(delay)
	effects.append_array(get_effects("harvest"))
	state = Enums.TileState.Empty
	on_yield_gained.emit(self, harvest_args)
	remove_seed()
	$HarvestParticles.emitting = true
	return effects

func remove_seed():
	if seed != null:
		seed.unregister_seed_events(event_manager)
	seed_base_yield = 0
	seed_grow_time = 0
	current_grow_progress = 0.0
	current_yield = 0.0
	$PlantSprite.visible = false
	seed = null
	state = Enums.TileState.Empty

func irrigate():
	if !irrigated:
		irrigated = true
		if not_destroyed():
			$Farmland.modulate = COLOR_IRRIGATE

func lose_irrigate():
	irrigated = false
	protected = false
	if not_destroyed():
		$Farmland.modulate = COLOR_NONE

func build_structure(n_structure: Structure, rotate):
	state = Enums.TileState.Structure
	structure = n_structure.copy()
	structure_rotate = rotate
	structure.register_events(event_manager, self)
	structure.grid_location = grid_location
	$PlantSprite.texture = n_structure.texture
	$PlantSprite.visible = true
	$PlantSprite.region_enabled = false
	var rest_position = $PlantSprite.position
	$PlantSprite.position += Vector2(0, -200)
	$PlantSprite.offset = Vector2(0, -8)
	$PlantSprite.scale = Vector2(1, 1)
	var tween = get_tree().create_tween()
	tween.tween_property($PlantSprite, "position", rest_position, 0.6).set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)

func preview_harvest() -> EventArgs.HarvestArgs:
	if seed != null:
		return seed.get_yield(self)
	return EventArgs.HarvestArgs.new(current_yield, purple, false)

func do_winter_clear():
	if state == Enums.TileState.Growing or state == Enums.TileState.Mature or destroyed:
		state = Enums.TileState.Empty
		destroyed = false
		remove_seed()
		lose_irrigate()
		update_purple_overlay()
	elif structure != null:
		structure.do_winter_clear()

func multiply_yield(strength):
	$AddYieldParticles.emitting = true
	current_yield *= strength
func add_yield(strength):
	$AddYieldParticles.emitting = true
	current_yield += strength

func get_turn_start_effects() -> Array[Effect]: 
	return get_effects("turn_start")

func get_before_grow_effects() -> Array[Effect]:
	return get_effects("before_grow")

func get_after_grow_effects() -> Array[Effect]:
	return get_effects("after_grow")

func get_effects(time) -> Array[Effect]:
	var effects_generated: Array[Effect] = []
	#TODO: Fix this unholy indentation
	if structure != null:
		for effect in structure.effects:
			if effect.on == time:
				var shape
				if effect.range == "adjacent":
					shape = Helper.get_tile_shape_rotated(structure.size, Enums.CursorShape.Elbow, structure_rotate)
				elif effect.range == "nearby":
					shape = Helper.get_tile_shape_rotated(structure.size, Enums.CursorShape.Elbow, structure_rotate)
				if shape != null:
					effects_generated.append_array(get_effects_in_shape(effect, shape))
	
	if seed != null:
		for effect in seed.effects:
			if effect.on == time:
				if effect.range == "adjacent":
					var shape = Helper.get_tile_shape_rotated(9, Enums.CursorShape.Square, 0)
					effects_generated.append_array(get_effects_in_shape(effect, shape))
				else:
					effects_generated.append(effect.copy().set_location(grid_location).set_card(seed))

	return effects_generated

func get_effects_in_shape(effect: Effect, shape):
	var effects: Array[Effect] = []
	for s in shape:
		var target = s + grid_location
		if Helper.in_bounds(target):
			effects.append(effect.copy().set_location(target).set_card(seed))
	return effects
	
func set_blight_targeted(value):
	blight_targeted = value
	$BlightTargetOverlay.visible = value

func set_destroy_targeted(value):
	destroy_targeted = value
	$DestroyTargetOverlay.visible = value

func set_blighted():
	notify_destroyed()
	remove_seed()
	blighted = true
	$PlantSprite.visible = false
	$Farmland.modulate = COLOR_BLIGHTED
	$DestroyParticles.emitting = true

func destroy():
	on_event.emit()
	destroyed = true
	$Farmland.modulate = COLOR_DESTROYED
	notify_destroyed()
	notify_tile_destroyed()
	remove_seed()
	update_purple_overlay()
	$DestroyParticles.emitting = true
	state = Enums.TileState.Empty

func destroy_plant():
	state = Enums.TileState.Empty
	notify_destroyed()
	remove_seed()
	$DestroyParticles.emitting = true

func update_purple_overlay():
	$PurpleOverlay.visible = purple and state != Enums.TileState.Inactive and not_destroyed()

func notify_harvest(delay: bool) -> EventArgs.HarvestArgs:
	var harvest_args: EventArgs.HarvestArgs = seed.get_yield(self)
	harvest_args.delay = harvest_args.delay or delay
	var specific_args = EventArgs.SpecificArgs.new(self)
	specific_args.harvest_args = harvest_args
	event_manager.notify_specific_args(EventManager.EventType.OnPlantHarvest, specific_args)
	return harvest_args

func notify_destroyed():
	event_manager.notify_specific_args(EventManager.EventType.OnPlantDestroyed,\
		EventArgs.SpecificArgs.new(self))

func notify_tile_destroyed():
	event_manager.notify_specific_args(EventManager.EventType.OnTileDestroyed,\
		EventArgs.SpecificArgs.new(self))

func remove_blight():
	blighted = false
	if structure != null:
		state = Enums.TileState.Structure
	else:
		state = Enums.TileState.Empty
	$Farmland.modulate = Color8(255, 255, 255)
	update_display()

func set_tile_size(n_size: Vector2):
	scale = n_size / Vector2(16, 16)
	$HarvestParticles.process_material.scale_min = 3.2
	$HarvestParticles.process_material.scale_max = 3.2
	$AddYieldParticles.process_material.scale_min = 2
	$AddYieldParticles.process_material.scale_max = 2
	$DestroyParticles.process_material.scale_min = 5
	$DestroyParticles.process_material.scale_max = 5
	$EffectParticles.process_material.scale_min = 1.5
	$EffectParticles.process_material.scale_max = 1.5
	
func remove_structure():
	structure.unregister_events(event_manager)
	structure = null
	$PlantSprite.visible = false
	state = Enums.TileState.Empty

func is_protected():
	return (Global.IRRIGATE_PROTECTED and irrigated) or protected

func show_peek():
	$PeekCont.visible = true
	$PeekCont/CenterCont/PeekLabel.text = str(round(current_yield))
	match state:
		Enums.TileState.Growing:
			$PeekCont/CenterCont/PeekLabel.set("theme_override_colors/font_color", Color8(168, 137, 34))
		Enums.TileState.Mature:
			$PeekCont/CenterCont/PeekLabel.set("theme_override_colors/font_color", Color8(15, 133, 20))
		_:
			$PeekCont.visible = false

func hide_peek():
	$PeekCont.visible = false

func not_destroyed():
	return !destroyed and !blighted

func is_destroyed():
	return destroyed or blighted

func card_can_target(card: CardData):
	if state == Enums.TileState.Inactive:
		return false
	var targets = []
	targets.assign(card.targets)
	if card.type == "SEED" and targets.size() == 0:
		targets.append("Empty");
	if state == Enums.TileState.Empty and (targets.has("Destroyed") or targets.has("Blighted")):
		return is_destroyed() or targets.has("Empty")
	return (targets.has(Enums.TileState.keys()[state]))\
		and (!destroyed or state != Enums.TileState.Empty or targets.has("Destroyed"))\
		and (!blighted or state != Enums.TileState.Empty or targets.has("Blighted"))

func structure_can_target():
	return state != Enums.TileState.Structure and state != Enums.TileState.Inactive and !blighted

func play_effect_particles():
	$EffectParticles.emitting = true
