extends StaticBody3D

class_name Building

var player : Spider

var mm : MultiMeshInstance3D
var i : int
var max_hp := 40
var hp := max_hp
var hp_bar_scene : PackedScene = preload("res://scenes/hp_bar.tscn")
var hp_bar : HpBar
var mass = 20

func _ready():
	#hp_bar = hp_bar_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	#hp_bar.transform = self.transform.translated_local(Vector3(0, 100, 0))
	#self.add_child(hp_bar)
	pass

func _process(delta):
	#hp_bar.set_hp(float(hp)/float(max_hp))
	pass

func hit(node, dmg_base : float = 1.0):
	hp -= dmg_base
	
	if hp <= 0:
		mm.multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3(0, -6000, 0)))
		
		if node != null and node.get("caught_objects") != null:
			reparent(node.caught_objects)
