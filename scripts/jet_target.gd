extends Area3D

@onready var jet = $"../.."

var mass = 20

func hit(node : Node3D):
	jet.hp -= 1
	
	if jet.hp == 0:
		jet.reparent(node.caught_objects)
		jet.dead = true
		queue_free()
