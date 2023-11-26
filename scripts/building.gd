extends StaticBody3D

class_name Building

var player : Spider
@export var achievement_manager : AchievementManager

var mm : MultiMeshInstance3D
var i : int
var max_hp := 40
var hp := max_hp
var hp_bar_scene : PackedScene = preload("res://scenes/hp_bar.tscn")
var hp_bar : HpBar
var mass = 20
var last_hit_frames : float = 100
var dead = false

var death_particles = preload("res://scenes/building_death.tscn")

func _ready():
	#hp_bar = hp_bar_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	#hp_bar.transform = self.transform.translated_local(Vector3(0, 100, 0))
	#self.add_child(hp_bar)
	pass

func _process(delta):
	last_hit_frames += delta
	
	if last_hit_frames <= 2.0:
		mm.multimesh.set_instance_custom_data(i, Color(1 - clampf(last_hit_frames * 4, 0.0, 1.0), 0, 0))

func hit(node, dmg_base : float = 1.0):
	hp -= dmg_base
	last_hit_frames = 0
	
	if hp <= 0 and !dead:
		dead = true
		if is_instance_of(node, Tentacle):
			achievement_manager.killed("building")
		
		mm.multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3(0, -6000, 0)))
		
		var particles = death_particles.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		particles.global_transform = global_transform
		get_tree().root.add_child(particles)
		
		if node != null and node.get("caught_objects") != null:
			reparent(node.caught_objects)
		else:
			queue_free()
