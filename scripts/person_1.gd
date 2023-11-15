extends CharacterBody3D

class_name Person

@export var player : Spider

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var collision_shape_3d = $CollisionShape3D
@onready var area_3d = $Area3D
@onready var hp_bar = $hp_bar

@onready
var hair_styles : Array[BoneAttachment3D] = [
	$"char_grp/rig/Skeleton3D/hair-1",
	$"char_grp/rig/Skeleton3D/hair-2",
	$"char_grp/rig/Skeleton3D/hair-3",
	$"char_grp/rig/Skeleton3D/hair-4",
	$"char_grp/rig/Skeleton3D/hair-5",
	$"char_grp/rig/Skeleton3D/hair-6",
	$"char_grp/rig/Skeleton3D/hair-7",
	$"char_grp/rig/Skeleton3D/hair-8"
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
	hp_bar.set_hp(float(hp)/float(hp_max))

	if dead:
		return

	var target = player.global_position
	target *= 6000 / target.distance_to(Vector3(0, -6000, 0))

	# TODO: This is fine but causes the piling issue ?
	look_at(target, Vector3.UP)
	translate_object_local(Vector3.BACK * delta * 5)
	
	var gravity = (Vector3(0, -6000, 0) - global_position).normalized() * 9.81 * delta
	
	if !is_on_floor():
		velocity += gravity
	
	# apply_floor_snap() ???
	
	move_and_slide()

func hit(node : Node3D):
	hp -= 1
	
	if hp == 0:
		collision_shape_3d.queue_free()
		area_3d.queue_free()
		reparent(node.caught_objects)
		dead = true
