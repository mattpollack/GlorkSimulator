extends Node3D

class_name Spider

@onready var limb_center = $limb_center
@onready var ground_ray = $ground_ray
@onready var forward_ray = $forward_ray

var tentacle_scene : PackedScene = preload("res://scenes/tentacle.tscn")

var speed_move : float = 30.0
var speed_turn : float = 2.0
var mouse_sensitivity : float = 0.2
var ground_offset : float = 1
var tentacles : Array[Tentacle] = []

func _ready():
	var tentacle_count : int = 10

	for i in range(tentacle_count):
		var tentacle : Tentacle = tentacle_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		tentacle.rotate(Vector3.UP, i * PI*2/tentacle_count + PI/4)
		limb_center.add_child(tentacle)
		tentacles.append(tentacle)

	for i in range(tentacle_count):
		tentacles[i].target_ik.neighbour = tentacles[(i + 1) % tentacles.size()].target_ik

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

	var target_basis := Utils.basis_from_normal(normal, transform, scale)
	var target_pos : Vector3 = ground_ray.get_collision_point()
	var target_normal : Vector3 = ground_ray.get_collision_normal()
	target_pos += target_normal * ground_offset

	transform.basis = lerp(transform.basis, target_basis, delta * 10).orthonormalized()
	global_position = lerp(global_position, target_pos, delta * 10)

	_handle_movement(delta)

func _input(event : InputEvent):
	if event is InputEventMouseMotion:
		rotate_object_local(Vector3.UP, deg_to_rad(-event.relative.x * mouse_sensitivity))

func _handle_movement(delta):
	var dir = Input.get_axis("forward", "backward")
	translate(Vector3(0, 0, dir) * speed_move * delta)

	dir = Input.get_axis("left", "right")
	translate(Vector3(dir, 0, 0) * speed_move * delta)
