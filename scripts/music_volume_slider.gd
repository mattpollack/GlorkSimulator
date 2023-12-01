extends Control

@onready var VolSliderMaster = $"."
var music_bus = AudioServer.get_bus_index("Master Music")

func _ready():
	VolSliderMaster.value = Utils.music_volume

func _on_value_changed(value):
	Utils.music_volume = value
	AudioServer.set_bus_volume_db(music_bus,value)
	
	if value == -30:
		AudioServer.set_bus_mute(music_bus,true)
	else:
		AudioServer.set_bus_mute(music_bus,false)
	
