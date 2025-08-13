extends Area3D

func _on_area_entered(area: Area3D) -> void:
	if area.get_parent() is PlayerCharacter: 
		if name == "FinishArea":
			pass
		else:
			pass
	else:
		pass
