extends Control

var master_bus = AudioServer.get_bus_index("Master")


func _on_toggled(button_pressed):
	AudioServer.set_bus_mute(master_bus,button_pressed)
