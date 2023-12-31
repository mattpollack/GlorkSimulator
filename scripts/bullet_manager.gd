extends Node3D

class_name BulletManager

var bullet_mesh : CylinderMesh = preload("res://raw/meshes/bullet.tres")
var laser_mesh : CylinderMesh = preload("res://raw/meshes/laser.tres")
var bullet_scene : PackedScene = preload("res://scenes/bullet.tscn")

@export var player : Spider
@export var building_generator : BuildingGenerator

const total = 5000

var mm_bullet := MultiMeshInstance3D.new()
var mm_laser := MultiMeshInstance3D.new()
var bullet_i := 0
var bullet_t := 0
var laser_i := 0
var laser_t := 0
var m := Mutex.new()

func _ready():
	mm_bullet.multimesh = MultiMesh.new()
	mm_bullet.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	mm_bullet.multimesh.mesh = bullet_mesh
	mm_bullet.multimesh.instance_count = total

	mm_laser.multimesh = MultiMesh.new()
	mm_laser.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	mm_laser.multimesh.mesh = laser_mesh
	mm_laser.multimesh.instance_count = total
	
	for i in range(total):
		mm_bullet.multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3(0, -60000, 0)))
		mm_laser.multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3(0, -60000, 0)))
	
	add_child(mm_bullet)
	add_child(mm_laser)

func _process(delta : float):
	if Utils.paused:
		return

	m.lock()
	
	_process_mm(delta, mm_bullet, "bullet_i", "bullet_t", 500, 1.5)
	_process_mm(delta, mm_laser, "laser_i", "laser_t", 5000, 15)
	
	m.unlock()

func _process_mm(delta : float, mm : MultiMeshInstance3D, i_str, t_str, speed, damage):
	var i : int = get(i_str)
	var t : int = get(t_str)
	
	for s in range(total):
		# Dumb way of skipping bad bullets
		if mm.multimesh.get_instance_transform(s).origin.distance_to(Vector3(0, -6000, 0)) > 10000:
			continue

		var moved := mm.multimesh.get_instance_transform(s).translated_local(Vector3.DOWN * delta * speed)
		
		var building_close := false
		
		if player.width() < 300:
			for n in player.relevant_targets:
				if is_instance_of(n, Building) and !n.dead and (sin((moved.origin - Vector3(0, 6000, 0)).angle_to(n.global_position - Vector3(0, 6000, 0))) * 6000 < 30 and moved.origin.distance_to(n.global_position) < 100):
					building_close = true
					n.hit(self, damage)
					break
		
		# Clean up bullets which are far from view
		if building_close or moved.origin.distance_to(Vector3(0, -6000, 0)) > 10000 or moved.origin.distance_to(Vector3(0, -6000, 0)) < 5985:
			i += 1
			i = i % total
			t = max(t - 1, 0)
			mm.multimesh.set_instance_transform(s, Transform3D(Basis.IDENTITY, Vector3(0, -60000, 0)))
		elif moved.origin.distance_to(player.aim_at_me.global_position) < player.width():
			i += 1
			i = i % total
			t = max(t - 1, 0)
			mm.multimesh.set_instance_transform(s, Transform3D(Basis.IDENTITY, Vector3(0, -60000, 0)))
			player.hit(null, damage)
		else:
			mm.multimesh.set_instance_transform(s, moved)
	
	set(i_str, i)
	set(t_str, t)
	
func fire(from : Transform3D):
	m.lock()
	mm_bullet.multimesh.set_instance_transform((bullet_i + bullet_t) % total, from.rotated_local(Vector3.MODEL_LEFT, PI/2))
	bullet_t += 1
	m.unlock()

func fire_laser(from : Transform3D):
	m.lock()
	mm_laser.multimesh.set_instance_transform((laser_i + laser_t) % total, from.rotated_local(Vector3.MODEL_LEFT, PI/2))
	laser_t += 1
	m.unlock()
