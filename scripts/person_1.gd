extends Node3D

class_name Person

var hair_styles : Array[MeshInstance3D] = [
	$"hair-1",
	$"hair-2",
	$"hair-3",
	$"hair-4",
	$"hair-5",
	$"hair-6",
	$"hair-7",
	$"hair-8"
]

func _ready():
	randomize()
	
	for h in hair_styles:
		h.hide()
	
	hair_styles[randi_range(0, hair_styles.size() - 1)].show()
	
	scale = Vector3(1, 1, 1) * randf_range(0.8, 1.5)
	#rotate_object_local(Vector3.UP, randf_range(0, PI*2))
