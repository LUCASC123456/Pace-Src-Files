extends Node

signal volumeChanged(busIndex: int, busName: String, soundValue: float)
signal muteChanged(muted: bool)
signal videoChanged(fullscreen: bool, resolution: Vector2i)
signal keybindChanged(action: String, event: InputEvent)

var volume : Dictionary = {}
var muted : bool = false
var fullscreen : bool = false
var resolution : Vector2i = Vector2i(1280, 720)
var keybinds : Dictionary = {}

# ------------------ AUDIO ------------------
func setVolume(busIndex: int, busName: String, soundValue: float):
	volume[busName] = soundValue
	emit_signal("volumeChanged", busIndex, busName, soundValue)

func setMute(state: bool):
	muted = state
	emit_signal("muteChanged", muted)

# ------------------ VIDEO ------------------
func setVideo(fs: bool, res: Vector2i):
	fullscreen = fs
	resolution = res
	emit_signal("videoChanged", fullscreen, resolution)

# ------------------ INPUT ------------------
func setKeybind(action: String, event: InputEvent):
	keybinds[action] = event
	emit_signal("keybindChanged", action, event)

	# Also update InputMap immediately (important for main menu remaps)
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	
func applyAllKeybinds():
	# Apply all stored keybinds into InputMap (useful when loading player scene)
	for action in keybinds.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybinds[action])
