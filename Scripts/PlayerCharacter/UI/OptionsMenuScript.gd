extends CanvasLayer

@export var pauseMenu : CanvasLayer
@export var mainMenu : CanvasLayer

@onready var inputKeybindBox : PackedScene = preload("res://Scenes/InputKeybindOptionScene.tscn")
@onready var controls : MarginContainer =  $TabContainer/CONTROLS
@onready var inputList : VBoxContainer = $TabContainer/CONTROLS/Control/ScrollContainer/InputList
@onready var resolOptionsButton : OptionButton = $TabContainer/VIDEO/CenterContainer/VBoxContainer/ResolutionOption/OptionButton

var isRemapping : bool = false
var actionToRemap = null
var remappingButton = null
var resList : Dictionary = {}
var inputActions : Dictionary = {
	"moveLeft" : "MOVE LEFT",
	"moveRight" : "MOVE RIGHT",
	"moveBackward" : "MOVE BACKWARD",
	"moveForward" : "MOVE FORWARD",
	"jump" : "JUMP",
	"run" : "RUN",
	"crouch | slide" : "CROUCH | SLIDE",
	"dash" : "DASH",
	"grappleHook" : "GRAPPLE HOOK",
	"pauseMenu" : "PAUSE MENU"
}
var masterBusIndex : int = AudioServer.get_bus_index("Master")
var optionsMenuEnabled : bool = false

const INPUT_BUTTON_MIN_SIZE = Vector2(110, 50)

# ------------------------ READY ------------------------
func _ready():
	setOptionsMenu(false)
	createInputsList()
	createResolutionsSelection()

	# Sync UI with global settings
	syncUiWithSettings()

	# Connect to SettingsManager signals
	SettingsManager.volumeChanged.connect(_on_volume_updated)
	SettingsManager.muteChanged.connect(_on_mute_updated)
	SettingsManager.videoChanged.connect(_on_video_updated)
	SettingsManager.keybindChanged.connect(_on_keybind_updated)

func _process(delta: float) -> void:
	if controls.visible:
		for child in inputList.get_children():
			if child is HBoxContainer:
				if child.custom_minimum_size != INPUT_BUTTON_MIN_SIZE:
					child.find_child("InputButton").custom_minimum_size = INPUT_BUTTON_MIN_SIZE
				else:
					pass
			else:
				pass
	else:
		pass

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
			SettingsManager.emit_signal("keybindChanged", action, ev)
		else:
			pass
		
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
	SettingsManager.setVideo(
		$TabContainer/VIDEO/CenterContainer/VBoxContainer/FullscreenOption/FullscreenCheckBox.button_pressed,
		SettingsManager.resolution
	)

func _on_option_button_item_selected(ind: int):
	var resWidth : int = resList[ind][0]
	var resHeight : int = resList[ind][1]
	SettingsManager.setVideo(SettingsManager.fullscreen, Vector2i(resWidth, resHeight))

# ------------------------ AUDIO ------------------------
func _on_check_box_pressed():
	SettingsManager.setMute($TabContainer/AUDIO/CenterContainer/VBoxContainer/VolumesSliders/MuteOption/CheckBox.button_pressed)

# ------------------------ SYNC ------------------------
func syncUiWithSettings():
	# Volume sliders
	for slider in $TabContainer/AUDIO/CenterContainer/VBoxContainer/VolumesSliders.get_children():
		if slider is HSlider:
			if slider.busName in SettingsManager.volume:
				slider.value = SettingsManager.volume[slider.busName]
			else:
				pass
		else:
			pass

	# Mute checkbox
	$TabContainer/AUDIO/CenterContainer/VBoxContainer/VolumesSliders/MuteOption/CheckBox.button_pressed = SettingsManager.muted

	# Resolution + fullscreen
	for i in resList.keys():
		if resList[i] == [SettingsManager.resolution.x, SettingsManager.resolution.y]:
			resolOptionsButton.select(i)
		else:
			pass
			
	$TabContainer/VIDEO/CenterContainer/VBoxContainer/FullscreenOption/FullscreenCheckBox.button_pressed = SettingsManager.fullscreen

func _on_volume_updated(busIndex: int, busName: String, soundValue: float):
	AudioServer.set_bus_volume_db(busIndex, linear_to_db(soundValue))
	for slider in $TabContainer/AUDIO/CenterContainer/VBoxContainer/VolumesSliders.get_children():
		if slider is HSlider and slider.busName == busName:
			slider.value = soundValue
		else:
			pass

func _on_mute_updated(muted: bool):
	$TabContainer/AUDIO/CenterContainer/VBoxContainer/VolumesSliders/MuteOption/CheckBox.button_pressed = muted
	AudioServer.set_bus_mute(masterBusIndex, false if muted else true)

func _on_video_updated(fullscreen: bool, resolution: Vector2i):
	$TabContainer/VIDEO/CenterContainer/VBoxContainer/FullscreenOption/FullscreenCheckBox.button_pressed = fullscreen
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	DisplayServer.window_set_size(Vector2i(resolution.x, resolution.y))
	for i in resList.keys():
		if resList[i] == [resolution.x, resolution.y]:
			resolOptionsButton.select(i)
		else:
			pass

func _on_keybind_updated(action: String, event: InputEvent):
	for inputBox in inputList.get_children():
		if inputBox.has_node("InputButton") and inputBox.has_node("ActionLabel"):
			var actionLabel = inputBox.get_node("ActionLabel")
			var inputButton = inputBox.get_node("InputButton")
			
			if action in inputActions and actionLabel.text == inputActions[action]:
				inputButton.text = event.as_text().trim_suffix("(Physical)")
			else:
				pass
		else:
			pass

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
