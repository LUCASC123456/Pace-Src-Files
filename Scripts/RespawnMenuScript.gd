extends CanvasLayer

@onready var respawnButton = $PanelContainer2/PanelContainer/CenterContainer/VBoxContainer/RespawnButton
var respawnMenuEnabled : bool = false
var mouseFree : bool = false 

func _ready() -> void:
	setRespawnMenu(false, false)

func setRespawnMenu(value : bool, enable : bool):
	#set the respawn menu behaviour (visibility, mouse control, ...)
	visible = value
	mouseFree = enable
	
	#handle mouse mode
	if mouseFree: 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else: 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_respawn_button_pressed() -> void:
	#this function is responsible for turning the dead body back to the player when they respawn by switching from rigidbody3d to characterbody3d whilst setting up the appropriate properties and calling the appropriate functions
	var playerScene = load("res://Scenes/PlayerCharacterScene.tscn")
	var player = playerScene.instantiate()
	get_tree().current_scene.add_child(player) 
	player.global_position = Vector3.ZERO #starting position of the player
	get_parent().queue_free()


func _on_respawn_menu_timer_timeout() -> void:
	#once the timer is finished, display the respawn menu to allow the player to respawn
	setRespawnMenu(true, true)
