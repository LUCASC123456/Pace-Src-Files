extends CanvasLayer

var mainMenuEnabled : bool = false
var mouseFree : bool = false 

@export var optionsMenu : CanvasLayer

func _ready():
	setMainMenu(true, true)
	
func setMainMenu(value : bool, enable : bool):
	#set the main menu behaviour (visibility, mouse control, ...)
	visible = value
	mouseFree = enable
	mainMenuEnabled = enable
	
	#stop game process when the main menu is enabled
	if mainMenuEnabled: 
		Engine.time_scale = 0.0
	else: 
		Engine.time_scale = 1.0
	
	#handle mouse mode
	if mouseFree: 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else: 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _on_play_button_pressed() -> void:
	var playerScene = load("res://Scenes/PlayerCharacterScene.tscn")
	var player = playerScene.instantiate()
	get_tree().current_scene.get_node("PlayerCharacter").add_child(player)
	
	var checkpoints = get_tree().current_scene.get_node("Map/CheckPoints")
	player.global_position = checkpoints.spawnPoint.global_position
	for checkPoint in checkpoints.get_children():
		checkPoint.entered = false
	
	#close main menu
	setMainMenu(false, false)

func _on_options_button_pressed():
	#close main menu, but keep it enabled, to block possible reopen while being on the options menu
	if optionsMenu != null:
		setMainMenu(false, true)
		optionsMenu.setOptionsMenu(true) #open options menu
	else:
		pass

func _on_quit_button_pressed() -> void:
	#close the window, and so close the game
	get_tree().quit()
