extends Control
@onready var optionsMenu : CanvasLayer = $".."

func _ready():
	set_process_input(true)

func _input(event):
	if optionsMenu.isRemapping:
		if (event is InputEventKey or (event is InputEventMouseButton and event.pressed)):
			if event is InputEventMouseButton and event.double_click:
				event.double_click = false
			else:
				pass
			
			# Apply change to SettingsManager (persistent global copy)
			SettingsManager.setKeybind(optionsMenu.actionToRemap, event)
			
			# Also apply immediately to InputMap (live controls)
			InputMap.action_erase_events(optionsMenu.actionToRemap)
			InputMap.action_add_event(optionsMenu.actionToRemap, event)
			
			# Update button text
			optionsMenu.remappingButton.text = event.as_text().trim_suffix("(Physical)")
			
			# Reset state
			optionsMenu.isRemapping = false
			optionsMenu.actionToRemap = null
			optionsMenu.remappingButton = null
			accept_event()
		else:
			pass
