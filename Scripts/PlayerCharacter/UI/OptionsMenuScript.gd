extends CanvasLayer

@onready var inputKeybindBox : PackedScene = preload("res://Scenes/InputKeybindOptionScene.tscn")
@onready var inputList : VBoxContainer = $TabContainer/Controls/Control/ScrollContainer/InputList

var isRemapping : bool = false
var actionToRemap = null
var remappingButton = null

@onready var resolOptionsButton : OptionButton = $TabContainer/Video/CenterContainer/VBoxContainer/ResolutionOption/OptionButton
var resList : Dictionary = {}

@export var pauseMenu : CanvasLayer
@export var mainMenu : CanvasLayer

var inputActions : Dictionary = {
	"moveLeft" : "Move left",
	"moveRight" : "Move right",
	"moveBackward" : "Move backward",
	"moveForward" : "Move forward",
	"jump" : "Jump",
	"run" : "Run",
	"crouch | slide" : "Crouch | Slide",
	"dash" : "Dash",
	"grappleHook" : "Grapple hook",
	"pauseMenu" : "Pause menu"
}

var optionsMenuEnabled : bool = false

# ------------------------ READY ------------------------
func _ready():
	setOptionsMenu(false)
	createInputsList()
	createResolutionsSelection()

	# Sync UI with global settings
	_sync_ui_with_settings()

	# Connect to SettingsManager signals
	SettingsManager.volume_changed.connect(_on_volume_updated)
	SettingsManager.mute_changed.connect(_on_mute_updated)
	SettingsManager.video_changed.connect(_on_video_updated)
	SettingsManager.keybind_changed.connect(_on_keybind_updated)

# ------------------------ STATE ------------------------
func setOptionsMenu(value : float):
	visible = value
	optionsMenuEnabled = value

# ------------------------ INPUT ------------------------
func createInputsList():
	InputMap.load_from_project_settings()

	# Clear old boxes
	for inputBoxIndex in inputList.get_children():
		inputBoxIndex.queue_free()

	for action in inputActions:
		var inputBox = inputKeybindBox.instantiate()
		var actionLabel = inputBox.find_child("ActionLabel")
		var inputButton = inputBox.find_child("InputButton")

		actionLabel.text = inputActions[action]

		# Prefer SettingsManager keybinds
		if SettingsManager.keybinds.has(action):
			inputButton.text = SettingsManager.keybinds[action].as_text().trim_suffix("(Physical)")
		else:
			var events = InputMap.action_get_events(action)
			if events.size() > 0:
				inputButton.text = events[0].as_text().trim_suffix("(Physical)")
				SettingsManager.keybinds[action] = events[0]
			else:
				inputButton.text = ""

		inputList.add_child(inputBox)
		inputButton.pressed.connect(_on_input_button_pressed.bind(inputButton, action))

		var horSepar : HSeparator = HSeparator.new()
		var horSeparTheme : Theme = Theme.new()
		horSepar.theme = horSeparTheme
		horSepar.modulate = Color(255, 255, 255, 0)
		inputList.add_child(horSepar)

func _on_input_button_pressed(inputButton, action):
	if !isRemapping:
		isRemapping = true
		actionToRemap = action
		remappingButton = inputButton
		inputButton.text = "..."
	else:
		pass

func _on_reset_button_pressed():
	# Reload default keybinds from project settings
	InputMap.load_from_project_settings()
	SettingsManager.keybinds.clear()

	# Repopulate SettingsManager with defaults and broadcast updates
	for action in inputActions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			var ev = events[0]
			SettingsManager.keybinds[action] = ev
			SettingsManager.emit_signal("keybind_changed", action, ev)

	# Rebuild UI for this OptionsMenu instance
	createInputsList()

# ------------------------ VIDEO ------------------------
func createResolutionsSelection():
	var resToAdd : Array = [[1920, 1080], [1280, 720], [1152, 648], [768, 432]]
	for res in range(0, resToAdd.size()):
		var widthVal = resToAdd[res][0]
		var heightVal = resToAdd[res][1]
		resList[res] = [widthVal, heightVal]
		resolOptionsButton.add_item(str(widthVal,"x",heightVal), res)
	resolOptionsButton.select(2)

func _on_fullscreen_check_box_pressed():
	SettingsManager.set_video(
		$TabContainer/Video/CenterContainer/VBoxContainer/FullscreenOption/FullscreenCheckBox.button_pressed,
		SettingsManager.resolution
	)

func _on_option_button_item_selected(ind: int):
	var resWidth : int = resList[ind][0]
	var resHeight : int = resList[ind][1]
	SettingsManager.set_video(SettingsManager.fullscreen, Vector2i(resWidth, resHeight))

# ------------------------ AUDIO ------------------------
func _on_check_box_pressed():
	SettingsManager.set_mute($TabContainer/Audio/CenterContainer/VBoxContainer/VolumeLabels/MuteOption/CheckBox.button_pressed)

# ------------------------ SYNC ------------------------
func _sync_ui_with_settings():
	# Volume sliders
	for slider in $TabContainer/Audio/CenterContainer/VBoxContainer/VolumesSliders.get_children():
		if slider is HSlider:
			if slider.busName in SettingsManager.volume:
				slider.value = SettingsManager.volume[slider.busName]

	# Mute checkbox
	$TabContainer/Audio/CenterContainer/VBoxContainer/VolumeLabels/MuteOption/CheckBox.button_pressed = SettingsManager.muted

	# Resolution + fullscreen
	for i in resList.keys():
		if resList[i] == [SettingsManager.resolution.x, SettingsManager.resolution.y]:
			resolOptionsButton.select(i)
	$TabContainer/Video/CenterContainer/VBoxContainer/FullscreenOption/FullscreenCheckBox.button_pressed = SettingsManager.fullscreen

func _on_volume_updated(bus_name: String, value: float):
	for slider in $TabContainer/Audio/CenterContainer/VBoxContainer/VolumesSliders.get_children():
		if slider is HSlider and slider.busName == bus_name:
			slider.value = value

func _on_mute_updated(muted: bool):
	$TabContainer/Audio/CenterContainer/VBoxContainer/VolumeLabels/MuteOption/CheckBox.button_pressed = muted

func _on_video_updated(fullscreen: bool, resolution: Vector2i):
	$TabContainer/Video/CenterContainer/VBoxContainer/FullscreenOption/FullscreenCheckBox.button_pressed = fullscreen
	for i in resList.keys():
		if resList[i] == [resolution.x, resolution.y]:
			resolOptionsButton.select(i)

func _on_keybind_updated(action: String, event: InputEvent):
	for inputBox in inputList.get_children():
		if inputBox.has_node("InputButton") and inputBox.has_node("ActionLabel"):
			var actionLabel = inputBox.get_node("ActionLabel")
			var inputButton = inputBox.get_node("InputButton")
			if action in inputActions and actionLabel.text == inputActions[action]:
				inputButton.text = event.as_text().trim_suffix("(Physical)")

# ------------------------ BACK ------------------------
func _on_back_button_pressed():
	if mainMenu != null:
		setOptionsMenu(false)
		mainMenu.setMainMenu(true, true)
	elif pauseMenu != null:
		setOptionsMenu(false)
		pauseMenu.setPauseMenu(true, true)
	else:
		pass
