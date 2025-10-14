extends HSlider

@export var busName : String
var busIndex : int

func _ready():
	busIndex = AudioServer.get_bus_index(busName)
	value_changed.connect(volumeValueChange)
	
	value = db_to_linear(AudioServer.get_bus_volume_db(busIndex))

func volumeValueChange(soundValue: float):
	SettingsManager.setVolume(busIndex, busName, soundValue)
