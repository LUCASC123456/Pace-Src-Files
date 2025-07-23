extends Control

#class name
class_name HUD

#references variables
@onready var velocityLabelText = $HBoxContainer/VBoxContainer2/SpeedLabelText
@onready var speedLinesContainer = $SpeedLinesContrainer

func _ready():
	speedLinesContainer.visible = false #the speed lines will only be displayed when the character will dashing
	
func displayVelocity(velocity : int):
	#this function manage the current velocity displayment
	velocityLabelText.set_text(str(velocity)+" M/S")
	
func displaySpeedLines(dashTime):
	#this function manage the speed lignes displayment (only when the character is dashing)
	speedLinesContainer.visible = true 
	#when the dash is finished, hide the speed lines
	await get_tree().create_timer(dashTime).timeout
	speedLinesContainer.visible = false 
