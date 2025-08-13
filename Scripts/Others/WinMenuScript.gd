extends CanvasLayer
 
@onready var timeTakenLabel = $PanelContainer2/PanelContainer/CenterContainer/VBoxContainer/TimeTakenLabel
@onready var distanceTravelledLabel = $PanelContainer2/PanelContainer/CenterContainer/VBoxContainer/DistanceTravelledLabel
@onready var damageDealthLabel = $PanelContainer2/PanelContainer/CenterContainer/VBoxContainer/DamageDealtLabel
@onready var exitButton = $PanelContainer2/PanelContainer/CenterContainer/VBoxContainer/ExitButton
var winMenuEnabled : bool = false
var mouseFree : bool = false
var timeTaken : float
var distanceTravelled : float
var damageDealt : int

@export var mainMenu : CanvasLayer

func _ready() -> void:
	setWinMenu(false, true)

func setWinMenu(value : bool, enable : bool):
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
		setWinMenu(false, true)
		mainMenu.setMainMenu(true, true) #open main menu
	else:
		pass

func _on_finish_area_area_entered(area: Area3D) -> void:
	if area.get_parent() is PlayerCharacter: 
		setWinMenu(true, true)
		timeTakenLabel.set_text("TIME TAKEN: " + str(int(timeTaken)) + "s")
		distanceTravelledLabel.set_text("DISTANCE TRAVELLED: " + str(int(distanceTravelled)) + "m")
		damageDealthLabel.set_text("DAMAGE DEALT: " + str(damageDealt) + "hp")
		
		timeTaken = 0
		distanceTravelled = 0
		damageDealt = 0
		
		area.get_parent().queue_free()
	else:
		pass
