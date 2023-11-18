extends Area3D

@onready var satellite = $"../.."

var mass = 200

func hit(node : Node3D):
	satellite.hp -= satellite.player.damage
	
	if satellite.hp <= 0:
		satellite.reparent(node.caught_objects)
		satellite.dead = true
		queue_free()
