extends Node3D

class_name Spider

@onready var limb_leg_center = $limb_leg_center
@onready var limb_arm_center = $limb_arm_center

@onready var ground_rays = $ground_rays
@onready var body = $body
@onready var aim_at_me = $body/aim_at_me
@onready var width_anchor = $body/width_anchor
@onready var death_particles = $death_particles
@onready var death_sound = $death_sound

@export var camera : Camera3D 
@export var camera_arm : Node3D 
@export var camera_anchor : Node3D 

signal killed_signal

var tentacle_scene : PackedScene = preload("res://scenes/tentacle.tscn")

var speed_move : float = 35.0
var speed_turn : float = 2.0
var mouse_sensitivity : float = 0.2
var ground_offset : float = 2
var tentacles_leg : Array[Tentacle] = []
var tentacles_arm : Array[Tentacle] = []
var tentacles_upgrade_count : float = 0
var nearby_enemies : Dictionary = {}
var relevant_targets : Dictionary = {}
var mass : float = 8.0
var mass_max : float = mass
var gravity_velocity = 0
var speed_upgrade : float = 1.0
var speed_upgrade_count : float = 0
var durability_upgrade : float = 0.5
var durability_upgrade_count : float = 0
var damage : float = 1
var damage_upgrade_count : float = 0
var dead : bool = false
var demo_dmg_multiplier : float = 0.3
var demo_mass_multiplier : float = 12.0

func _ready():
	_set_tentacle_count(4)

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

func upgrade_damage(price) -> bool:
	if mass > price:
		mass -= price
		damage += 1
		damage_upgrade_count += 1
		
		return true
	
	return false
func upgrade_speed(price) -> bool:
	if mass > price:
		mass -= price
		speed_upgrade += 0.5
		speed_upgrade_count += 1
		
		return true
	
	return false

func upgrade_tentacles(price) -> bool:
	if mass > price:
		mass -= price
		tentacles_upgrade_count += 1
		_set_tentacle_count(tentacles_leg.size() + 1)
		
		return true
	
	return false

func upgrade_durability(price) -> bool:
	
	durability_upgrade_count += 1

	if mass > price:
		mass -= price
		durability_upgrade = pow(durability_upgrade_count, -1)
		
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
		tentacle.translate_object_local(Vector3(mass/(6*limb_leg_center.scale.length()), 0, 0))
		tentacle.rotate(Vector3.UP, PI/2)
		tentacle.player = self
		limb_leg_center.add_child(tentacle)
		tentacles_leg.append(tentacle)

	for i in range(tentacle_count):
		var tentacle : Tentacle = tentacle_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		tentacle.rotate(Vector3.LEFT, -PI/8)
		tentacle.rotate(Vector3.UP, i * PI*2/tentacle_count + PI/4 + PI/tentacle_count)
		tentacle.translate_object_local(Vector3(mass/(5*limb_arm_center.scale.length()), 0, 0))
		tentacle.rotate(Vector3.UP, PI/2)
		tentacle.player = self
		tentacle.should_step = false
		tentacle.should_attack = true
		limb_arm_center.add_child(tentacle)
		tentacles_arm.append(tentacle)

	for i in range(tentacle_count):
		tentacles_leg[i].target_ik.neighbour = tentacles_leg[(i + 1) % tentacles_leg.size()].target_ik
		tentacles_arm[i].target_ik.neighbour = tentacles_arm[(i + 1) % tentacles_arm.size()].target_ik

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
	if Utils.paused:
		return
	
	if mass == 0 and !dead:
		dead = true
		death_particles.emitting = true
		body.hide()
		limb_arm_center.hide()
		limb_leg_center.hide()
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -30.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), -30.0)
		death_sound.finished.connect(func():
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), 0.0)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), 0.0)
			Utils.game_over = true
			Utils.played_a_game = true
			)
		death_sound.play()
	
	if dead:
		return
	
	if mass >= 15000:
		Utils.game_win = true
		Utils.played_a_game = true

	mass_max = max(mass_max, mass)
	var target_mass : float = maxf(maxf(mass, mass_max/4), 4.0) # don't let the player get to 1/4 of their highest mass achievement
	var target_scale = Vector3(1.0, 1.0, 1.0) * target_mass / 10
	ground_offset = lerp(ground_offset, target_mass/8, delta)
	speed_move = target_mass + sqrt(target_mass) * 10 * speed_upgrade - 5
	
	if Utils.game_win:
		target_mass = 60000
		global_position = lerp(global_position, Vector3(0, -6000 - width(), 0), delta)
		global_rotation = lerp(global_rotation, Vector3(0, 0, 0), delta)
		target_scale = Vector3(9000, 9000, 9000)
		limb_arm_center.hide()
		limb_leg_center.hide()
	
	body.scale = lerp(body.scale, target_scale/1.6, delta)
	death_particles.scale = lerp(death_particles.scale, target_scale/1.6, delta)
	death_particles.process_material.scale_min = lerp(death_particles.process_material.scale_min, target_scale.length()/1.6, delta)
	death_particles.process_material.scale_max = lerp(death_particles.process_material.scale_max, target_scale.length()*4/1.6, delta)
	
	camera.position.z = lerp(camera.position.z, target_mass - 15, delta)
	camera.near = lerp(camera.near, target_mass / 1000, delta)
	camera.far = lerp(camera.far, float(clamp(target_mass * 10, 4000, 64000)), delta)
	
	camera_arm.rotation.x = clampf(camera_arm.rotation.x, -PI/4 + 0.01, PI/4 - 0.01)
	camera_arm.rotation.y = 0
	camera_arm.rotation.z = 0
	
	limb_leg_center.scale = lerp(limb_leg_center.scale, target_scale, delta)
	limb_arm_center.scale = lerp(limb_arm_center.scale, target_scale, delta)
	
	for t in tentacles_leg:
		t.target_ik.step_distance = target_mass / 2

	for t in tentacles_arm:
		t.attack_speed = (speed_move / 4 + target_mass/5) * speed_upgrade + 4
		t.target_ik.step_distance = target_mass / 2
	
	if Utils.game_win:
		return
	
	# Apply movement and rotation transformations
	_set_ground_ray_targets(target_mass/4)

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
	
		global_rotation.x = (global_position - Vector3(0, 6000, 0)).angle_to(Vector3(1, 0, 0))
		global_rotation.y = (global_position - Vector3(0, 6000, 0)).angle_to(Vector3(0, 1, 0))
		global_rotation.z = (global_position - Vector3(0, 6000, 0)).angle_to(Vector3(0, 0, 1))
	
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
	if Utils.paused or Utils.game_win:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_object_local(Vector3.UP, deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera_arm.rotate_object_local(Vector3.LEFT, deg_to_rad(event.relative.y * mouse_sensitivity))

func _handle_movement(delta):
	var dir = Input.get_axis("forward", "backward")
	translate(Vector3(0, 0, dir) * speed_move * delta)

	dir = Input.get_axis("left", "right")
	translate(Vector3(dir, 0, 0) * speed_move * delta)

func width() -> float:
	return aim_at_me.global_position.distance_to(width_anchor.global_position) * 2

func hit(node : Node3D, dmg_base : float = 0.75):
	if Utils.game_win:
		return
	var multiplier = demo_dmg_multiplier if Utils.demo else 1

	var dmg = dmg_base * durability_upgrade * multiplier
	mass = clamp(mass - dmg, 0, 20000)

func killed(n : Node3D):
	var multiplier = demo_mass_multiplier if Utils.demo else 1
	if n.get("mass") != null:
		mass += n.get("mass") * multiplier
	else:
		mass += multiplier

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

func _on_close_area_area_entered(area):
	if !area.is_in_group("enemy"):
		return
	
	relevant_targets[area] = true

func _on_close_area_area_exited(area):
	if !area.is_in_group("enemy"):
		return

	relevant_targets.erase(area)

func _on_close_area_body_entered(body):
	if !body.is_in_group("enemy"):
		return

	relevant_targets[body] = true

func _on_close_area_body_exited(body):
	if !body.is_in_group("enemy"):
		return

	relevant_targets.erase(body)
