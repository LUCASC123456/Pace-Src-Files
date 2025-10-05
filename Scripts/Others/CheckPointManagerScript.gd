extends Node3D

signal lose

@onready var spawnPoint = $Checkpoints/StartCheckpoint
@onready var objectivePoint = $Checkpoints/Checkpoint
@onready var checkPointIndex = 0


func _on_checkpoint_timer_timeout() -> void:
	lose.emit()
	spawnPoint = get_node("Checkpoints/StartCheckpoint")
	objectivePoint = get_node("Checkpoints/Checkpoint")
	checkPointIndex = 0
