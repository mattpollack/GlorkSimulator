extends Area3D

@onready var spider : Spider = $"../../.."

func hit(node : Node3D, dmg_base : float = 1.0):
	spider.hit(node, dmg_base)
