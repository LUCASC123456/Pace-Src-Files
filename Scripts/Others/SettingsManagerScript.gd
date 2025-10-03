extends Node

signal volume_changed(bus_name: String, value: float)
signal mute_changed(muted: bool)
signal video_changed(fullscreen: bool, resolution: Vector2i)
signal keybind_changed(action: String, event: InputEvent)

var volume : Dictionary = {}
var muted : bool = false
var fullscreen : bool = false
var resolution : Vector2i = Vector2i(1280, 720)
var keybinds : Dictionary = {}

# ------------------ AUDIO ------------------
func set_volume(bus_name: String, value: float):
	volume[bus_name] = value
	emit_signal("volume_changed", bus_name, value)

func set_mute(state: bool):
	muted = state
	emit_signal("mute_changed", muted)

# ------------------ VIDEO ------------------
func set_video(fs: bool, res: Vector2i):
	fullscreen = fs
	resolution = res
	emit_signal("video_changed", fullscreen, resolution)

# ------------------ INPUT ------------------
func set_keybind(action: String, event: InputEvent):
	keybinds[action] = event
	emit_signal("keybind_changed", action, event)

	# Also update InputMap immediately (important for main menu remaps)
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	
func apply_all_keybinds():
	# Apply all stored keybinds into InputMap (useful when loading player scene)
	for action in keybinds.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybinds[action])
