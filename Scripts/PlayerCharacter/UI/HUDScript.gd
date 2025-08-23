extends Control

#class name
class_name HUD

#references variables
@onready var player = $".."
@onready var speedUI = $SpeedUI
@onready var checkpointUI = $CheckpointUI
@onready var healthUI = $HealthUI
@onready var speedLinesContainer = $SpeedLinesContainer
@onready var bloodContainer = $BloodContainer

func _ready():
	healthUI.max_value = player.health
	speedLinesContainer.visible = false #the speed lines will only be displayed when the character will dashing
	
func displayVelocity(velocity : int):
	#this function manage the current velocity displayment
	speedUI.set_text(str(velocity)+" M/S")
	
func displayCheckPoints():
	var checkpoints = get_tree().current_scene.get_node("Map/CheckPoints")
	checkpointUI.set_text(str(checkpoints.checkPointIndex) + "/" + str(checkpoints.get_child_count()))
	
func displayHealth():
	healthUI.value = player.remainingHealth
	
func displaySpeedLines(dashTime):
	#this function manage the speed lignes displayment (only when the character is dashing)
	speedLinesContainer.visible = true 
	#when the dash is finished, hide the speed lines
	await get_tree().create_timer(dashTime).timeout
	speedLinesContainer.visible = false

func displayBlood(radius):
	bloodContainer.material.set_shader_parameter("radius", radius)
