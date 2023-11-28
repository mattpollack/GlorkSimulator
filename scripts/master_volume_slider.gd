extends Control

@onready var VolSliderMaster = $"."
var master_bus = AudioServer.get_bus_index("Master")

func _ready():
	VolSliderMaster.value = AudioServer.get_bus_volume_db(master_bus)
	pass
	

func _on_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus,value)
	
	if value == -30:
		AudioServer.set_bus_mute(master_bus,true)
	else:
		AudioServer.set_bus_mute(master_bus,false)
