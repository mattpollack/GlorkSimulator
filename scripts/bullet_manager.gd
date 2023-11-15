extends Node3D

class_name BulletManager

var bullet_mesh : CylinderMesh = preload("res://raw/meshes/bullet.tres")

@export var player : Spider

const total = 5000

var mm := MultiMeshInstance3D.new()
var i := 0
var t := 0
var m := Mutex.new()

func _ready():
	mm.multimesh = MultiMesh.new()
	mm.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	mm.multimesh.mesh = bullet_mesh
	mm.multimesh.instance_count = total
	
	add_child(mm)

func _process(delta : float):
	m.lock()

	for s in range(total):
		var moved := mm.multimesh.get_instance_transform(s).translated_local(Vector3.DOWN * delta * 500)
		
		# Clean up bullets which are far from view
		if moved.origin.distance_to(Vector3(0, -6000, 0)) > 7500:
			i += 1
			i = i % total
			t = max(t - 1, 0)
			mm.multimesh.set_instance_transform(s, Transform3D(Basis.IDENTITY, Vector3(0, -6000, 0)))
		elif moved.origin.distance_to(player.aim_at_me.global_position) < player.width():
			i += 1
			i = i % total
			t = max(t - 1, 0)
			mm.multimesh.set_instance_transform(s, Transform3D(Basis.IDENTITY, Vector3(0, -6000, 0)))
			player.hit()
		else:
			mm.multimesh.set_instance_transform(s, moved)
	
	m.unlock()

func fire(from : Transform3D):
	m.lock()
	mm.multimesh.set_instance_transform((i + t) % total, from.rotated_local(Vector3.MODEL_LEFT, PI/2))
	t += 1
	m.unlock()
