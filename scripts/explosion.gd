extends Node3D

class_name Explosion

@onready var head = $head
@onready var tunnel = $tunnel
@onready var ring = $ring

func _ready():
	head.emitting = false
	tunnel.emitting = false
	ring.emitting = false
	head.one_shot = true
	tunnel.one_shot = true
	ring.one_shot = true

func explode():
	head.restart()
	tunnel.restart()
	ring.restart()
	head.emitting = true
	tunnel.emitting = true
	ring.emitting = true
