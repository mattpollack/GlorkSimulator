extends Area3D

@onready var satellite = $"../.."

var mass = 200

func hit(node : Node3D, dmg_base : float = 1.0):
	satellite.hp -= dmg_base
	
	if satellite.hp <= 0:
		satellite.achievement_manager.killed("satellite")
		if node != null and node.get("caught_objects") != null:
			satellite.reparent(node.caught_objects)
		satellite.dead = true
		queue_free()
