extends CanvasLayer

var pauseMenuEnabled : bool = false
var mouseFree : bool = false 

@export var optionsMenu : CanvasLayer 

func _ready():
	setPauseMenu(false, false)
	
func _process(_delta):
	#this function manage the mouse state
	#when the mouse is captured, you can't see it, and she's disable (not for the movement detection, but for the on screen inputs)
	#when the mouse is visible, you can see it, and she's enable
	if Input.is_action_just_pressed("pauseMenu"):
		if !optionsMenu.optionsMenuEnabled:
			if pauseMenuEnabled: 
				setPauseMenu(false, false)
			else: 
				setPauseMenu(true, true)
		else:
			pass
	else:
		pass
		
func setPauseMenu(value : bool, enable : bool):
	#set the pause menu behaviour (visibility, mouse control, ...)
	visible = value
	mouseFree = enable
	pauseMenuEnabled = enable
	
	#stop game process when the pause menu is enabled
	if pauseMenuEnabled: 
		Engine.time_scale = 0.0
	else: 
		Engine.time_scale = 1.0
	
	#handle mouse mode
	if mouseFree: 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else: 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _on_resume_button_pressed():
	#close pause menu
	setPauseMenu(false, false)
	
func _on_options_button_pressed():
	#close pause menu, but keep it enabled, to block possible reopen while being on the options menu
	if optionsMenu != null:
		setPauseMenu(false, true)
		optionsMenu.setOptionsMenu(true) #open options menu
	else:
		pass
	
func _on_quit_button_pressed():
	#close the window, and so close the game
	get_tree().quit()
	
