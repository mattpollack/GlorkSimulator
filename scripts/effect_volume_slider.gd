extends Control

@onready var VolSliderMaster = $"."
var effects_bus = AudioServer.get_bus_index("Master Effects")

func _ready():
	VolSliderMaster.value = Utils.effect_volume
	pass
	

func _on_value_changed(value):
	Utils.effect_volume = value
	AudioServer.set_bus_volume_db(effects_bus,value)
	
	if value == -30:
		AudioServer.set_bus_mute(effects_bus,true)
	else:
		AudioServer.set_bus_mute(effects_bus,false)
