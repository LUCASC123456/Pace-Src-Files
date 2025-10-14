extends CanvasLayer

@onready var respawnButton = $Control/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/VBoxContainer/RespawnButton
@onready var winMenu = $"../../../Camera/Camera3D/WinMenu"
@onready var loseMenu = $"../../../Camera/Camera3D/LoseMenu"

var mouseFree : bool = false 

func _ready() -> void:
	setRespawnMenu(false, false)

func _process(delta: float) -> void:
	winMenu.timeTaken += delta
	loseMenu.timeTaken += delta

func setRespawnMenu(value : bool, enable : bool):
	#set the respawn menu behaviour (visibility, mouse control, ...)
	visible = value
	mouseFree = enable
	
	if mouseFree: 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else: 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_respawn_button_pressed() -> void:
	var playerScene = load("res://Scenes/PlayerCharacterScene.tscn")
	var player = playerScene.instantiate()
	get_tree().current_scene.get_node("PlayerCharacter").add_child(player)
	
	var spawnPoint = get_tree().current_scene.get_node("Map/Objectives").spawnPoint
	player.global_position = spawnPoint.global_position
	
	get_parent().queue_free()


func _on_respawn_menu_timer_timeout() -> void:
	setRespawnMenu(true, true)
