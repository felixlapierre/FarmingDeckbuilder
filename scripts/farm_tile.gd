extends MarginContainer

enum {
	Empty,
	Destroyed,
	Growing,
	Mature
}
var state = Empty # Store the state of the farm tile
var grid_location: Vector2
var TILE_SIZE = Vector2(56, 56);
var FARM_DIMENSIONS = Vector2(6, 6);
var objects_image = "res://assets/1616tinygarden/objects.png"

var seed = null # To contain information about the seed being grown here

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_tile_button_mouse_entered() -> void:
	$"../../".on_tile_hover(grid_location)

func _on_tile_button_mouse_exited() -> void:
	$"../../".clear_overlay()

func _on_tile_button_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("leftclick"):
		if Global.selected_card.type == "Seed":
			$"../../".use_card(Global.selected_card, grid_location)

func plant_seed(seed):
	seed = Global.selected_card
	$PlantSprite.texture = load(objects_image)
	$PlantSprite.region_enabled = true
	$PlantSprite.set_region_rect(Rect2(seed.texture * 16, 32, 16, 16))
