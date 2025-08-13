extends CanvasLayer

@onready var respawnButton = $PanelContainer2/PanelContainer/CenterContainer/VBoxContainer/RespawnButton
var mouseFree : bool = false 

func _ready() -> void:
	setRespawnMenu(false, false)

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
	player.global_position = Vector3.ZERO
	get_parent().queue_free()


func _on_respawn_menu_timer_timeout() -> void:
	setRespawnMenu(true, true)
