extends CanvasLayer

@export var leaderboard : CanvasLayer
@export var optionsMenu : CanvasLayer

@onready var levelUI = $Control/MarginContainer/HBoxContainer/Control/LevelsUI

var mainMenuEnabled : bool = false
var mouseFree : bool = false 

func _ready():
	setMainMenu(true, true)

func _process(delta: float) -> void:
	levelUI.text = "LEVEL: " + str(int(floor(SaveManager.saveData["level"])))

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
	
	var objectives = get_tree().current_scene.get_node("Map/Objectives")
	var checkpoints = objectives.get_node("Checkpoints")
	player.global_position = objectives.spawnPoint.global_position
	for checkPoint in checkpoints.get_children():
		checkPoint.entered = false
	
	#close main menu
	setMainMenu(false, false)

func _on_leaderboard_button_pressed() -> void:
	if leaderboard != null:
		setMainMenu(false, true)
		leaderboard.setLeaderboard(true) #open leaderboard menu
	else:
		pass

func _on_options_button_pressed() -> void:
	#close main menu, but keep it enabled, to block possible reopen while being on the options menu
	if optionsMenu != null:
		setMainMenu(false, true)
		optionsMenu.setOptionsMenu(true) #open options menu
	else:
		pass

func _on_quit_button_pressed() -> void:
	#close the window, and so close the game
	get_tree().quit()
