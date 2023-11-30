extends Control

var master_bus = AudioServer.get_bus_index("Master")


func _on_toggled(button_pressed):
	AudioServer.set_bus_mute(master_bus, button_pressed)

func _input(e: InputEvent):
	if e.is_action_pressed("mute"):
		var current_mute_state = AudioServer.is_bus_mute(master_bus)
		var new_mute_state = !current_mute_state
		_on_toggled(new_mute_state)
