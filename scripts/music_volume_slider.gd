extends Control

@onready var VolSliderMaster = $"."
var music_bus = AudioServer.get_bus_index("Music")

func _ready():
	VolSliderMaster.value = AudioServer.get_bus_volume_db(music_bus)
	pass
	

func _on_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus,value)
	
	if value == -30:
		AudioServer.set_bus_mute(music_bus,true)
	else:
		AudioServer.set_bus_mute(music_bus,false)
	
