extends Node3D

class_name Spider

@onready var limb_center = $limb_center
@onready var ground_ray = $ground_ray
@onready var forward_ray = $forward_ray
@onready var body = $body

@export var camera : Camera3D 
@export var camera_arm : Node3D 
@export var camera_anchor : Node3D 

var tentacle_scene : PackedScene = preload("res://scenes/tentacle.tscn")

var speed_move : float = 30.0
var speed_turn : float = 2.0
var mouse_sensitivity : float = 0.2
var ground_offset : float = 2
var tentacles : Array[Tentacle] = []

func _ready():
	_set_tentacle_count(6)

func _set_tentacle_count(tentacle_count : int) -> void:
	for n in limb_center.get_children():
		n.queue_free()
	
	tentacles = []
	
	for i in range(tentacle_count):
		var tentacle : Tentacle = tentacle_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		tentacle.rotate(Vector3.UP, i * PI*2/tentacle_count + PI/4)
		limb_center.add_child(tentacle)
		tentacles.append(tentacle)

	for i in range(tentacle_count):
		tentacles[i].target_ik.neighbour = tentacles[(i + 1) % tentacles.size()].target_ik
	
	#print(scale)

	#scale.x = 0.1 + 0.1 * tentacle_count
	#scale.y = 0.1 + 0.1 * tentacle_count
	#scale.z = 0.1 + 0.1 * tentacle_count

func _process(delta):
	var forward_target = forward_ray.get_collision_point()
	var offset = clamp(abs(global_position.distance_to(forward_target)), 1, 15)
	
	for t in tentacles:
		t.offset = offset
		t.target_ik.speed_move = speed_move/8
	
	var normal := Vector3.ZERO
	
	for i in range(tentacles.size()):
		normal += Plane(
			tentacles[(i - 0) % tentacles.size()].target_step.global_position,
			tentacles[(i - 1) % tentacles.size()].target_step.global_position,
			tentacles[(i - 2) % tentacles.size()].target_step.global_position,
		).normal
	
	normal /= tentacles.size()
	normal = normal.normalized()
	
	# Scale up basically everything except the root node since that seems to break things
	# TODO:
	# - Ray distances of legs
	var target_scale = Vector3(1.0, 1.0, 1.0) * float(tentacles.size()) / 10
	
	# Scale up the tentacle nodes, TODO ray distances 
	for t in tentacles:
		t.scale = target_scale
	
	body.scale = target_scale/1.6
	camera.position.z = tentacles.size() - 15
	ground_offset = tentacles.size()/4
	ground_ray.target_position.y = -ground_offset - 10
	forward_ray.target_position.y = -ground_offset - 10
	speed_move = tentacles.size() * 30 / 8
	
	# Apply movement and rotation transformations
	var target_basis := Utils.basis_from_normal(normal.normalized(), transform, scale)
	var target_pos : Vector3 = ground_ray.get_collision_point()
	var target_normal : Vector3 = ground_ray.get_collision_normal()
	target_pos += target_normal * ground_offset
	
	transform.basis = lerp(transform.basis, target_basis.orthonormalized(), delta * 10)
	global_position = lerp(global_position, target_pos, delta * 10)
	
	_handle_movement(delta)
	
	camera_arm.global_position = global_position

func _input(event : InputEvent):
	if event is InputEventMouseMotion:
		rotate_object_local(Vector3.UP, deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera_arm.rotate_object_local(Vector3.LEFT, deg_to_rad(event.relative.y * mouse_sensitivity))
		camera_arm.rotation.x = clampf(camera_arm.rotation.x, -PI/4, PI/4)

	if Input.is_action_just_pressed("debug_increase_size"):
		_set_tentacle_count(tentacles.size()+1)

func _handle_movement(delta):
	var dir = Input.get_axis("forward", "backward")
	translate(Vector3(0, 0, dir) * speed_move * delta)

	dir = Input.get_axis("left", "right")
	translate(Vector3(dir, 0, 0) * speed_move * delta)
