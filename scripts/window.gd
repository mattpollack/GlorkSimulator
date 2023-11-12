extends Node3D

class_name GlassWindow

@onready var window = $window
@onready var window_broken = $"window-broken"
@onready var window_area = $window_area
@onready var shatter = $shatter

var broken := false

func _ready():
	window.show()
	window_area.show()
	window_broken.hide()
	
func break_glass() -> void:
	if broken:
		return
	
	shatter.emitting = true
	broken = true
	window.hide()
	window_area.hide()
	window_broken.show()

func _on_window_area_area_entered(area):
	break_glass()

func _on_window_area_body_entered(body):
	return
#	break_glass()
