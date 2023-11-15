extends Node3D

class_name Spider

@onready var limb_leg_center = $limb_leg_center
@onready var limb_arm_center = $limb_arm_center

@onready var ground_rays = $ground_rays
@onready var body = $body
@onready var aim_at_me = $body/aim_at_me
@onready var width_anchor = $body/width_anchor

@export var camera : Camera3D 
@export var camera_arm : Node3D 
@export var camera_anchor : Node3D 

signal killed_signal

var tentacle_scene : PackedScene = preload("res://scenes/tentacle.tscn")

var speed_move : float = 30.0
var speed_turn : float = 2.0
var mouse_sensitivity : float = 0.2
var ground_offset : float = 2
var tentacles_leg : Array[Tentacle] = []
var tentacles_arm : Array[Tentacle] = []
var nearby_enemies : Dictionary = {}
var mass : float = 8.0
var gravity_velocity = 0
var speed_upgrade : float = 1.0
var durability_upgrade : float = 1.0

func _ready():
	_set_tentacle_count(4)

func upgrade_speed(price) -> bool:
	if mass > price:
		mass -= price
		speed_upgrade += 0.5
		
		return true
	
	return false

func upgrade_tentacles(price) -> bool:
	if mass > price:
		mass -= price
		_set_tentacle_count(tentacles_leg.size() + 1)
		
		return true
	
	return false

func upgrade_durability(price) -> bool:
	if mass > price:
		mass -= price
		durability_upgrade *= 0.8
		
		return true
	
	return false

func _set_tentacle_count(tentacle_count : int) -> void:
	for n in limb_leg_center.get_children():
		n.queue_free()

	for n in limb_arm_center.get_children():
		n.queue_free()
	
	tentacles_leg = []
	tentacles_arm = []
	
	for i in range(tentacle_count):
		var tentacle : Tentacle = tentacle_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		tentacle.rotate(Vector3.UP, i * PI*2/tentacle_count + PI/4)
		tentacle.translate_object_local(Vector3(mass/8, 0, 0))
		tentacle.rotate(Vector3.UP, PI/2)
		tentacle.player = self
		limb_leg_center.add_child(tentacle)
		tentacles_leg.append(tentacle)

	for i in range(tentacle_count):
		var tentacle : Tentacle = tentacle_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		tentacle.rotate(Vector3.UP, i * PI*2/tentacle_count + PI/4)
		tentacle.translate_object_local(Vector3(mass/8, 0, 0))
		tentacle.rotate(Vector3.UP, PI/2)
		tentacle.player = self
		tentacle.should_step = false
		tentacle.should_attack = true
		limb_arm_center.add_child(tentacle)
		tentacles_arm.append(tentacle)

	for i in range(tentacle_count):
		tentacles_leg[i].target_ik.neighbour = tentacles_leg[(i + 1) % tentacles_leg.size()].target_ik
		tentacles_arm[i].target_ik.neighbour = tentacles_arm[(i + 1) % tentacles_arm.size()].target_ik

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
	var point : Vector3 = Vector3(0, 0, 0)
	var normal : Vector3 = Vector3(0, 0, 0)
	var valid := false
	
	for ray_node in ground_rays.get_children():
		var ray = ray_node as RayCast3D
		
		if ray.is_colliding():
			i += 1
			point += ray.get_collision_point()
			normal += ray.get_collision_normal()
	
	if i != 0:
		point /= i
		normal /= i
		valid = true
	
	return [point, normal.normalized(), valid]

func _set_ground_ray_targets(offset : float) -> void:
	for ray_node in ground_rays.get_children():
		var ray = ray_node as RayCast3D
		ray.target_position.y = -offset - 12

func _process(delta):
	var target_scale = Vector3(1.0, 1.0, 1.0) * mass / 10
	ground_offset = lerp(ground_offset, mass/8, delta)
	speed_move = mass + sqrt(mass) * 10 * speed_upgrade
	
	body.scale = lerp(body.scale, target_scale/1.6, delta)
	
	camera.position.z = lerp(camera.position.z, mass - 15, delta)
	camera.near = lerp(camera.near, mass / 1000, delta)
	camera.far = lerp(camera.far, float(clamp(mass * 10, 4000, 64000)), delta)
	
	for t in tentacles_leg:
		t.scale = lerp(t.scale, target_scale, delta)
		t.target_ik.speed_move = (mass * mass / 10) * speed_upgrade
		t.target_ik.step_distance = sqrt(mass) + mass / 2
		t.tentacle_tip_shape.scale = Vector3.ONE * (1 + mass/8.0)

	for t in tentacles_arm:
		t.scale = lerp(t.scale, target_scale, delta)
		t.attack_speed = (speed_move / 4 + mass/5) * speed_upgrade
		t.target_ik.speed_move = mass * mass / 10
		t.target_ik.step_distance = sqrt(mass) + mass / 2
		t.tentacle_tip_shape.scale = Vector3.ONE * (1 + mass/8.0)
	
	# Apply movement and rotation transformations
	_set_ground_ray_targets(mass/4)

	var point_and_norm = _ground_point_and_norm()
	var ground_point : Vector3 = point_and_norm[0]
	var ground_norm : Vector3 = point_and_norm[1]
	var valid : bool = point_and_norm[2]
	
	if valid:
		gravity_velocity = 0
		var target_basis := Utils.basis_from_normal(ground_norm, transform, scale)
		ground_point += ground_norm * ground_offset
	
		transform.basis = lerp(transform.basis, target_basis.orthonormalized(), delta * 10).orthonormalized()
		global_position = lerp(global_position, ground_point, delta * 10)
	
		_handle_movement(delta)
	else:
		if global_position.distance_to(Vector3(0, -6000, 0)) > 6000:
			gravity_velocity += -9.81 * delta
			global_position += (global_position - Vector3(0, -6000, 0)).normalized() * gravity_velocity
		else:
			global_position += (global_position - Vector3(0, -6000, 0)).normalized()
	
	camera_arm.global_position = global_position
	
	var i := 0
	
	for t in tentacles_arm:
		t.attack_target = null
		t.should_attack = false
	
	for k in nearby_enemies.keys():
		var nearest : float = INF
		var tn : Tentacle = null
		
		for t in tentacles_arm:
			if t.attack_target != null:
				continue
			
			var distance = t.global_position.distance_to(k.global_position)
			
			if distance < nearest:
				nearest = distance
				tn = t
		
		if tn != null:
			tn.attack_target = k
			tn.should_attack = true

func _input(event : InputEvent):
	if event is InputEventMouseMotion:
		rotate_object_local(Vector3.UP, deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera_arm.rotate_object_local(Vector3.LEFT, deg_to_rad(event.relative.y * mouse_sensitivity))
		camera_arm.rotation.x = clampf(camera_arm.rotation.x, -PI/4 + 0.01, PI/4 - 0.01)

	#if Input.is_action_just_pressed("debug_increase_size"):
	#	mass += mass
	#	_set_tentacle_count(tentacles_arm.size()+1)

func _handle_movement(delta):
	var dir = Input.get_axis("forward", "backward")
	translate(Vector3(0, 0, dir) * speed_move * delta)

	dir = Input.get_axis("left", "right")
	translate(Vector3(dir, 0, 0) * speed_move * delta)

func width() -> float:
	return aim_at_me.global_position.distance_to(width_anchor.global_position) * 2

# TODO hit amounts
func hit():
	var dmg = 0.025 * durability_upgrade
	mass = clamp(mass - dmg, 8, 20000)

func killed(n : Node3D):
	if n.get("mass") != null:
		mass += n.get("mass")
	else:
		mass += 1
	
	killed_signal.emit()

func _on_reach_area_area_entered(area):
	if !area.is_in_group("enemy"):
		return
	
	nearby_enemies[area] = true

func _on_reach_area_area_exited(area):
	if !area.is_in_group("enemy"):
		return

	nearby_enemies.erase(area)

func _on_reach_area_body_entered(body):
	if !body.is_in_group("enemy"):
		return

	nearby_enemies[body] = true

func _on_reach_area_body_exited(body):
	if !body.is_in_group("enemy"):
		return

	nearby_enemies.erase(body)
