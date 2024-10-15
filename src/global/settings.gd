extends Node
class_name Settings

static var DEBUG: bool = false
static var TUTORIALS_ENABLED: bool = true
static var CLICK_MODE: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

static func save_settings():
	var settings_json = {
		"debug": DEBUG,
		"tutorials": TUTORIALS_ENABLED,
		"click_mode": CLICK_MODE
	}
	var settings = FileAccess.open("user://settings.save", FileAccess.WRITE)
	settings.store_line(JSON.stringify(settings_json))

static func load_settings():
	if not FileAccess.file_exists("user://settings.save"):
		return null
	var settings_fileread = FileAccess.open("user://settings.save", FileAccess.READ)
	var settings_data = settings_fileread.get_line()
	var json = JSON.new()
	var parse_result = json.parse(settings_data)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message())
		return
	var settings_json = json.get_data()
	DEBUG = settings_json.debug
	TUTORIALS_ENABLED = settings_json.tutorials
	CLICK_MODE = (settings_json.has("click_mode") and settings_json.click_mode) or false
