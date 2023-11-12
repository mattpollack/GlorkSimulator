extends Node3D

class_name Spider

@onready var limb_center = $limb_center
@onready var ground_rays = $ground_rays
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

var mass : float = 4.0

func _ready():
	_set_tentacle_count(3)

func _set_tentacle_count(tentacle_count : int) -> void:
	for n in limb_center.get_children():
		n.queue_free()
	
	tentacles = []
	
	for i in range(tentacle_count):
		var tentacle : Tentacle = tentacle_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		tentacle.rotate(Vector3.UP, i * PI*2/tentacle_count + PI/4)
		tentacle.translate_object_local(Vector3(1, 0, 0))
		tentacle.rotate(Vector3.UP, PI/2)
		limb_center.add_child(tentacle)
		tentacles.append(tentacle)

	for i in range(tentacle_count):
		tentacles[i].target_ik.neighbour = tentacles[(i + 1) % tentacles.size()].target_ik

	for y in range(0, 360, 360/3):
		for x in range(0, 72, 72/3):
			var ray_outer := RayCast3D.new()
			ray_outer.rotation = Vector3(deg_to_rad(x), 0, 0)
			ray_outer.rotate(Vector3.UP, deg_to_rad(y))
			ray_outer.target_position = Vector3(0, -100, 0)
			ray_outer.exclude_parent = true
			
			var ray_inner := RayCast3D.new()
			ray_inner.rotation = Vector3(deg_to_rad(x), 0, 0)
			ray_inner.rotate(Vector3.UP, deg_to_rad(y))
			ray_inner.translate(Vector3(3, 0, 0))
			ray_inner.rotate(Vector3.UP, deg_to_rad(90))
			ray_inner.target_position = Vector3(0, -100, 0)
			ray_inner.exclude_parent = true
			
			ground_rays.add_child(ray_outer)
			ground_rays.add_child(ray_inner)

func _ground_point_and_norm() -> Array:
	var i = 0
	var point : Vector3
	var normal : Vector3
	
	for ray_node in ground_rays.get_children():
		var ray = ray_node as RayCast3D
		
		if ray.is_colliding():
			i += 1
			point += ray.get_collision_point()
			normal += ray.get_collision_normal()
	
	point /= i
	normal /= i
	
	return [point, normal.normalized()]

func _ground_point_and_norm_old() -> Array:
	var points : Dictionary = {}
	var normals : Dictionary = {}
	
	for ray_node in ground_rays.get_children():
		var ray = ray_node as RayCast3D
		
		if ray.is_colliding():
			points[ray.get_collision_point()] = true
			normals[ray.get_collision_normal()] = true
	
	var point : Vector3
	var normal : Vector3
	
	for p in points.keys():
		point += p
	
	for n in normals.keys():
		normal += n
	
	return [point / points.keys().size(), normal / normals.keys().size()]

func _set_ground_ray_targets(offset : float) -> void:
	for ray_node in ground_rays.get_children():
		var ray = ray_node as RayCast3D
		ray.target_position.y = -offset - 12

func _process(delta):
	var target_scale = Vector3(1.0, 1.0, 1.0) * mass / 10
	ground_offset = mass/8
	speed_move = mass + sqrt(mass) * 10
	
	body.scale = target_scale/1.6
	
	camera.position.z = mass - 15
	camera.near = mass / 1000
	camera.far = clamp(mass * 10, 4000, 64000)
	
	for t in tentacles:
		t.scale = target_scale
		t.target_ik.speed_move = mass * mass / 10
		t.target_ik.step_distance = sqrt(mass) + mass / 2
		t.tentacle_tip_shape.scale = Vector3.ONE * (1 + mass/8.0)
	
	# Apply movement and rotation transformations
	_set_ground_ray_targets(mass/4)

	var point_and_norm = _ground_point_and_norm()
	var ground_point : Vector3 = point_and_norm[0]
	var ground_norm : Vector3 = point_and_norm[1]
	var target_basis := Utils.basis_from_normal(ground_norm, transform, scale)
	ground_point += ground_norm * ground_offset
	
	transform.basis = lerp(transform.basis, target_basis.orthonormalized(), delta * 10).orthonormalized()
	global_position = lerp(global_position, ground_point, delta * 10)
	
	_handle_movement(delta)
	
	camera_arm.global_position = global_position

func _input(event : InputEvent):
	if event is InputEventMouseMotion:
		rotate_object_local(Vector3.UP, deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera_arm.rotate_object_local(Vector3.LEFT, deg_to_rad(event.relative.y * mouse_sensitivity))
		camera_arm.rotation.x = clampf(camera_arm.rotation.x, -PI/4, PI/4)

	if Input.is_action_just_pressed("debug_increase_size"):
		mass += mass
		_set_tentacle_count(tentacles.size()+1)

func _handle_movement(delta):
	var dir = Input.get_axis("forward", "backward")
	translate(Vector3(0, 0, dir) * speed_move * delta)

	dir = Input.get_axis("left", "right")
	translate(Vector3(dir, 0, 0) * speed_move * delta)
