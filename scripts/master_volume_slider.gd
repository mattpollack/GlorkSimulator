extends Control

@onready var VolSliderMaster = $"."
var master_bus = AudioServer.get_bus_index("Master")

func _ready():
	VolSliderMaster.value = Utils.master_volume

func _on_value_changed(value):
	Utils.master_volume = value
	AudioServer.set_bus_volume_db(master_bus,value)
	
	if value == -30:
		AudioServer.set_bus_mute(master_bus,true)
	else:
		AudioServer.set_bus_mute(master_bus,false)
