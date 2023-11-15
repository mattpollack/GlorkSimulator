extends Control

@export var player : Spider

@onready var bg : ColorRect = $_/health_parent/health_container/bg
@onready var value : ColorRect = $_/health_parent/health_container/value
@onready var threat = $_/threat

var max_mass = 0
var max_threat = 0

func _process(delta):
	max_mass = max(max_mass, player.mass)
	max_threat = max(max_threat, player.mass / 15000)

	value.custom_minimum_size.x = clamp(player.mass / 15000, 0, 1) * bg.size.x
	threat.text = "%f" % max_threat
