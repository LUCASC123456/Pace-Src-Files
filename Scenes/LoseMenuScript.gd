extends CanvasLayer
 
@onready var timeTakenLabel = $PanelContainer2/PanelContainer/CenterContainer/VBoxContainer/TimeTakenLabel
@onready var distanceTravelledLabel = $PanelContainer2/PanelContainer/CenterContainer/VBoxContainer/DistanceTravelledLabel
@onready var damageDealthLabel = $PanelContainer2/PanelContainer/CenterContainer/VBoxContainer/DamageDealtLabel
@onready var exitButton = $PanelContainer2/PanelContainer/CenterContainer/VBoxContainer/ExitButton

var timeTaken : float
var distanceTravelled : float
var damageDealt : int
var winMenuEnabled : bool = false
var mouseFree : bool = false

@export var mainMenu : CanvasLayer
@export var winMenu : CanvasLayer

func _ready() -> void:
	setLoseMenu(false, true)

func setLoseMenu(value : bool, enable : bool):
	#set the respawn menu behaviour (visibility, mouse control, ...)
	visible = value
	mouseFree = enable
	winMenuEnabled = enable
	
	if mouseFree: 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else: 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if winMenuEnabled:
		Engine.time_scale = 0.0
	else:
		Engine.time_scale = 1.0

func _on_exit_button_pressed() -> void:
	if mainMenu != null:
		setLoseMenu(false, true)
		mainMenu.setMainMenu(true, true) #open main menu
	else:
		pass


func _on_objectives_lose() -> void:
	timeTakenLabel.set_text("TIME TAKEN: " + str(int(timeTaken)) + "s")
	distanceTravelledLabel.set_text("DISTANCE TRAVELLED: " + str(int(distanceTravelled)) + "m")
	damageDealthLabel.set_text("DAMAGE DEALT: " + str(damageDealt) + "hp")
	
	timeTaken = 0
	distanceTravelled = 0
	damageDealt = 0
	winMenu.timeTaken = 0
	winMenu.distanceTravelled = 0
	winMenu.damageDealt = 0
	
	if get_tree().current_scene.get_node("PlayerCharacter").get_child(0) is PlayerCharacter:
		var player = get_tree().current_scene.get_node("PlayerCharacter").get_child(0)
		player.queue_free()
	elif get_tree().current_scene.get_node("PlayerCharacter").get_child(0) is RigidBody3D:
		var deadBody = get_tree().current_scene.get_node("PlayerCharacter").get_child(0)
		deadBody.queue_free()
	else:
		pass
	
	setLoseMenu(true, true)
