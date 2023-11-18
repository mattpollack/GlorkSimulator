extends Area3D

@onready var jet = $"../.."

var mass = 20

func hit(node : Node3D, dmg_base : float = 1.0):
	jet.hp -= dmg_base
	
	if jet.hp <= 0:
		if node != null and node.get("caught_objects") != null:
			jet.reparent(node.caught_objects)
		jet.dead = true
		queue_free()
