extends Area3D

signal win

@onready var entered : bool = false

func _process(delta: float) -> void:
	var objectivePointMarker = self.get_node("WaypointAnchor/Control")
	
	if Engine.time_scale == 1.0:
		if get_parent().get_parent().objectivePoint == self:
			objectivePointMarker.visible = true
		else:
			objectivePointMarker.visible = false
	else:
		objectivePointMarker.visible = false

func _on_area_entered(area: Area3D) -> void:
	if area.get_parent() is PlayerCharacter:
		for checkPoint in get_parent().get_children():
			if checkPoint == self:
				if !entered:
					get_parent().get_parent().get_node("CheckpointTimer").stop()
					
					if self == get_parent().get_node("FinishCheckpoint"):
						win.emit(area)
						get_parent().get_parent().spawnPoint = get_parent().get_node("StartCheckpoint")
						get_parent().get_parent().objectivePoint = get_parent().get_node("Checkpoint")
						get_parent().get_parent().checkPointIndex = 0
					else:
						entered = true
						get_parent().get_parent().spawnPoint = self
						get_parent().get_parent().objectivePoint = get_parent().get_children()[get_parent().get_children().find(self) + 1]
						get_parent().get_parent().checkPointIndex += 1
						get_parent().get_parent().get_node("CheckpointTimer").start()
				else:
					pass
				break
			else:
				if !checkPoint.entered:
					break
				else:
					pass
	else:
		pass
