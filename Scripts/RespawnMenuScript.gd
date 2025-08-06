extends CanvasLayer

@onready var respawnButton = $PanelContainer2/PanelContainer/CenterContainer/VBoxContainer/RespawnButton
var respawnMenuEnabled : bool = false
var mouseFree : bool = false 

func _ready() -> void:
	setRespawnMenu(false, false)

func setRespawnMenu(value : bool, enable : bool):
	#set the respawn menu behaviour (visibility, mouse control, ...)
	visible = value
	mouseFree = value
	respawnMenuEnabled = enable
	
	if mouseFree: 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else: 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if respawnMenuEnabled:
		respawnButton.disabled = false
	else:
		respawnButton.disabled = true


func _on_respawn_button_pressed() -> void:
	var playerScene = load("res://Scenes/PlayerCharacterScene.tscn")
	var player = playerScene.instantiate()
	get_tree().current_scene.add_child(player)  # Or add to a specific node if needed
	player.global_position = Vector3.ZERO
	get_parent().queue_free()


func _on_respawn_menu_timer_timeout() -> void:
	setRespawnMenu(true, true)
