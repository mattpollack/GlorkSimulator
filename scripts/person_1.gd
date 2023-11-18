extends Node3D

class_name Person

@export var player : Spider
@export var bullet_manager : BulletManager
@onready var collision_shape_3d = $CollisionShape3D

@onready var animation_tree : AnimationTree = $AnimationTree

@onready
var hair_styles : Array[BoneAttachment3D] = [
	$"person-1/char_grp/rig/Skeleton3D/hair-1",
	$"person-1/char_grp/rig/Skeleton3D/hair-2",
	$"person-1/char_grp/rig/Skeleton3D/hair-3",
	$"person-1/char_grp/rig/Skeleton3D/hair-4",
	$"person-1/char_grp/rig/Skeleton3D/hair-5",
	$"person-1/char_grp/rig/Skeleton3D/hair-6",
	$"person-1/char_grp/rig/Skeleton3D/hair-7",
	$"person-1/char_grp/rig/Skeleton3D/hair-8"
]

var mass = 1
var dead := false
var hp_max := 1
var hp := hp_max

func _ready():
	randomize()
	
	for h in hair_styles:
		h.hide()

	hair_styles[randi_range(0, hair_styles.size() - 1)].show()
	
	scale = Vector3(1, 1, 1) * randf_range(0.8, 1.5)
	run()

func idle():
	animation_tree.set("parameters/conditions/idle", true)

func walk():
	animation_tree.set("parameters/conditions/walk", true)

func run():
	animation_tree.set("parameters/conditions/run", true)

func _process(delta):
	if dead:
		return
	
	if global_position.distance_to(player.global_position) > 100:
		queue_free()
		dead = true

	# TODO: This is fine but causes the piling issue ?
	look_at(player.global_position, Vector3.UP)
	translate_object_local(Vector3.BACK * delta * 8)
	global_position = global_position.move_toward(Vector3(0, -6000, 0), global_position.distance_to(Vector3(0, -6000, 0)) - 5984)
	
	var gravity = (Vector3(0, -6000, 0) - global_position).normalized() * 9.81 * delta

func hit(node : Node3D, dmg_base : float = 1.0):
	hp -= dmg_base
	
	if hp <= 0:
		collision_shape_3d.queue_free()
		if node != null and node.get("caught_objects") != null:
			reparent(node.caught_objects)
		dead = true
