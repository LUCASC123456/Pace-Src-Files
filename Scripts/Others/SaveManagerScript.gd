extends Node

const SAVEPATH := "user://machine_save.json"

var saveData := {
	"level" : 1.0,
	"bestTime" : 999999,         # Large initial value so lower times overwrite
	"lowestDistance" : 999999,   # Large initial value so lower distances overwrite
	"leastDamage" : 999999      # Large initial value so lower damage overwrites
}

func _ready():
	loadGame()
	
## LOAD THE SAVE FILE (if exists)
func loadGame() -> void:
	if FileAccess.file_exists(SAVEPATH):
		var file := FileAccess.open(SAVEPATH, FileAccess.READ)
		
		if file:
			var content := file.get_as_text()
			var data : Dictionary = JSON.parse_string(content)
			
			if typeof(data) == TYPE_DICTIONARY:
				saveData = data
			else:
				pass
				
			file.close()
		else:
			pass
	else:
		pass

## SAVE THE CURRENT DATA TO FILE
func saveToFile() -> void:
	var file := FileAccess.open(SAVEPATH, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(saveData))
		file.close()
	else:
		pass

## UPDATE THE STATS AFTER A GAME
func updateStatsWin(time : int, distance : int, damage : int) -> void:
	var isNewFile := not FileAccess.file_exists(SAVEPATH)

	# Always overwrite level
	if time == 0:
		var scaler = pow(10, round(log(distance*damage)/log(10)))
		saveData["level"] += scaler/(int(floor(saveData["level"]))*distance*damage)
	elif distance == 0:
		var scaler = pow(10, round(log(time*damage)/log(10)))
		saveData["level"] += scaler/(int(floor(saveData["level"]))*time*damage)
	elif damage == 0:
		var scaler = pow(10, round(log(time*distance)/log(10)))
		saveData["level"] += scaler/(int(floor(saveData["level"]))*time*distance)
	else:
		var scaler = pow(10, round(log(time*distance*damage)/log(10)))
		saveData["level"] += scaler/(int(floor(saveData["level"]))*time*distance*damage)

	# If it's the first game, store everything
	if isNewFile:
		saveData["bestTime"] = time
		saveData["lowestDistance"] = distance
		saveData["leastDamage"] = damage
	else:
		# Only overwrite stats if new values are lower
		if time < saveData["bestTime"]:
			saveData["bestTime"] = time
		else:
			pass
			
		if distance < saveData["lowestDistance"]:
			saveData["lowestDistance"] = distance
		else:
			pass
			
		if damage < saveData["leastDamage"]:
			saveData["leastDamage"] = damage
		else:
			pass
	
	saveToFile()
	
func updateStatsLose(time : int, distance : int, damage : int):
	var isNewFile := not FileAccess.file_exists(SAVEPATH)
	
	# Always overwrite level
	if time == 0:
		var scaler = pow(10, round(log(distance*damage)/log(10)))
		saveData["level"] += scaler/(int(floor(saveData["level"]))*distance*damage)
	elif distance == 0:
		var scaler = pow(10, round(log(time*damage)/log(10)))
		saveData["level"] += scaler/(int(floor(saveData["level"]))*time*damage)
	elif damage == 0:
		var scaler = pow(10, round(log(time*distance)/log(10)))
		saveData["level"] += scaler/(int(floor(saveData["level"]))*time*distance)
	else:
		var scaler = pow(10, round(log(time*distance*damage)/log(10)))
		saveData["level"] += scaler/(int(floor(saveData["level"]))*time*distance*damage)
	
	saveToFile() 
