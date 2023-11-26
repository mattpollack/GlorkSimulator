extends Area3D

@onready var mech : Mech = $".."

var mass = 100

func hit(node : Node3D, dmg_base : float = 1.0):
	mech.hp -= dmg_base
	
	if mech.hp <= 0:
		if is_instance_of(node, Tentacle):
			mech.achievement_manager.killed("mech")
		if node != null and node.get("caught_objects") != null:
			mech.reparent(node.caught_objects)
		mech.dead = true
		queue_free()
